//
//  mainshader.metal
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/8.
//

#include <metal_stdlib>
using namespace metal;

struct RenderConfig {
    // Image Config
    float imageWidth;
    float imageHeight;
    float aspectRatio;
    float gameTime;
    // Render Config
    float samples_per_pixel;
    float max_depth;
    // random seed
    float tickSeed;
    // Camera Config
    float viewportHeight;
    float viewportWidth;
    float focalLength;
    float vfov;
    float3 origin;
    float3 horizontal;
    float3 vertical;
    float3 lower_left_corner;
    float3 lookfrom;
    float3 lookat;
    float3 vup;
    float3 spherePos;
};

// Generate a random float in the range [0.0f, 1.0f] using x, y, and z (based on the xor128 algorithm)
float randomer_gen_float(thread const uint2& position, int z)
{
    int seed = position.x + position.y * 57 + z * 241;
    seed= (seed<< 13) ^ seed;
    return (( 1.0 - ( (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647) / 1073741824.0f) + 1.0f) / 2.0f;
}

float degrees_to_radians(float degrees) {
    return degrees * 3.1415926 / 180.0;
}

float3 randomer_gen_float3(thread const uint2& position, int seed) {
    return float3(randomer_gen_float(position, seed+1), randomer_gen_float(position, seed+2), randomer_gen_float(position, seed+3));
}

float3 unit_vector(float3 v) {
    return v / length(v);
}

float3 random_in_unit_sphere(thread const uint2& position, float seed) {
    int threshold = 3; // set max loop for my random algorithm, or it will got into dead loop
    while (threshold--) {
        float3 p = float3(randomer_gen_float(position, seed+1), randomer_gen_float(position, seed+2), randomer_gen_float(position, seed+3));
        if (length_squared(p) >= 0.99f) { continue; }
        return p;
    }
    return float3(randomer_gen_float(position, seed+1), randomer_gen_float(position, seed+2), randomer_gen_float(position, seed+3));
}

float3 random_unit_vector(thread const uint2& position, float seed) {
    return unit_vector(random_in_unit_sphere(position, seed));
}

float3 random_in_hemisphere(thread const float3& normal, thread const uint2& position, float seed) {
    float3 in_unit_sphere = random_in_unit_sphere(position, seed+1);
    if (dot(in_unit_sphere, normal) > 0.01f)
        return in_unit_sphere;
    else
        return -in_unit_sphere;
}

bool near_zero(float3 v) {
    float s = 1e-8;
    return (fabs(v.x) < s) && (fabs(v.y) < s) && (fabs(v.z) < s);
}

class Ray {
public:
    Ray() {}
    Ray(float3 origin, float3 direction) : orig(origin), dir(direction) {}
    
    inline float3 origin() const     { return orig; }
    inline float3 direction() const  { return dir; }
    inline float3 at(float t) const  { return orig + t * dir; }
    
public:
    float3 orig;   //point3
    float3 dir;    //vec3
};

class Lambertian;
class Metal;
class Dielectric;
class Irradiator;

struct HitRecord {
    float3 p;      //point3
    float3 normal; //vec3
    thread Lambertian* lam_mat_ptr;
    thread Metal* met_mat_ptr;
    thread Dielectric* die_mat_ptr;
    thread Irradiator* irr_mat_ptr;
    int mat_id; /* 1-Lambertian 2-Metal 3-Dielectric 4-Irradiator */
    float t;
    bool front_face;
    
    inline void set_face_normal(thread const Ray& r, thread const float3& outward_normal) {
        front_face = dot(r.direction(), outward_normal) < 0;
        normal = front_face ? outward_normal : -outward_normal;
    }
};

class Sphere {
public:
    Sphere() {}
    Sphere(float3 cen, float r, thread Lambertian* lmp) : center(cen), radius(r), lam_mat_ptr(lmp) { mat_id = 1; };
    Sphere(float3 cen, float r, thread Metal* met) : center(cen), radius(r), met_mat_ptr(met) { mat_id = 2; };
    Sphere(float3 cen, float r, thread Dielectric* die) : center(cen), radius(r), die_mat_ptr(die) { mat_id = 3; };
    Sphere(float3 cen, float r, thread Irradiator* irr) : center(cen), radius(r), irr_mat_ptr(irr) { mat_id = 4; };
    
    bool intersect(thread const Ray& r, float t_min, float t_max, thread HitRecord& rec) {
        float3 oc = r.origin() - center;
        float a = length_squared(r.direction());
        float half_b = dot(oc, r.direction());
        float c = length_squared(oc) - radius*radius;
        
        float discriminant = half_b*half_b - a*c;
        if (discriminant < 0) return false;
        auto sqrtd = sqrt(discriminant);
        
        auto root = (-half_b - sqrtd) / a;
        if (root < t_min || t_max < root) {
            root = (-half_b + sqrtd) / a;
            if (root < t_min || t_max < root)
                return false;
        }
        
        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p - center) / radius;
        float3 outward_normal = (rec.p - center) / radius;
        rec.set_face_normal(r, outward_normal);
        // make use to copy all the material
        rec.lam_mat_ptr = lam_mat_ptr;
        rec.met_mat_ptr = met_mat_ptr;
        rec.die_mat_ptr = die_mat_ptr;
        rec.irr_mat_ptr = irr_mat_ptr;
        rec.mat_id = mat_id; // make sure HitRecord use the right material
        
        return true;
    }
    
public:
    float3 center; //point3
    float radius;
    thread Lambertian* lam_mat_ptr;
    thread Metal* met_mat_ptr;
    thread Dielectric* die_mat_ptr;
    thread Irradiator* irr_mat_ptr;
    int mat_id; /* 1-Lambertian 2-Metal 3-Dielectric 4-Irradiator */
};

class Camera {
public:
    Camera(float3 lookfrom,
           float3 lookat,
           float3 vup,
           float vfov,
           float aspect_ratio) {
        float theta = degrees_to_radians(vfov);
        float h = tan(theta/2);
        float viewport_height = 2.0 * h;
        float viewport_width = aspect_ratio * viewport_height;
        
        float3 w = unit_vector(lookfrom - lookat);
        float3 u = unit_vector(cross(vup, w));
        float3 v = cross(w, u);
        
        origin = lookfrom;
        horizontal = viewport_width * u;
        vertical = viewport_height * v;
        lower_left_corner = origin - horizontal/2 - vertical/2 - w;
    }
    
    Ray get_ray(float s, float t) const {
        return Ray(origin, lower_left_corner + s*horizontal + t*vertical - origin);
    }
    
public:
    float3 origin; //point3
    float3 lower_left_corner; //point3
    float3 horizontal; //vec3
    float3 vertical; //vec3
};

class Lambertian {
public:
    Lambertian() {}
    Lambertian(thread const float3& a) : albedo(a) {}
    
    bool radiate(thread const Ray& r_in,
                 thread const HitRecord& rec,
                 thread float3& attenuation,
                 thread Ray& radiated,
                 thread const uint2& position, float seed) const {
        
        float3 radiate_direction = rec.normal + random_unit_vector(position, seed);

        if (near_zero(radiate_direction))
            radiate_direction = rec.normal;
        
        radiated = Ray(rec.p, radiate_direction);
        attenuation = albedo;
        return true;
    }
    
public:
    float3 albedo; //color
};

class Metal {
public:
    Metal(thread const float3& a, float f) : albedo(a), fuzz(f < 1 ? f : 1) {}
    
    bool radiate(thread const Ray& r_in,
                 thread const HitRecord& rec,
                 thread float3& attenuation,
                 thread Ray& radiated,
                 thread const uint2& position, float seed) const {
        float3 reflected = reflect(unit_vector(r_in.direction()), rec.normal);
        radiated = Ray(rec.p, reflected + fuzz * randomer_gen_float3(position, seed+1));
                       
        attenuation = albedo;
        return (dot(radiated.direction(), rec.normal) > 0);
    }
    
public:
    float3 albedo; //color
    float fuzz;
};

class Irradiator {
public:
    Irradiator() {}
    Irradiator(thread const float3& a, thread const float& i) : albedo(a), intensity(i) {}
    
    bool radiate(thread const Ray& r_in,
                 thread const HitRecord& rec,
                 thread float3& attenuation,
                 thread Ray& radiated,
                 thread const uint2& position, float seed) const {
        
        float3 radiate_direction = rec.normal + random_unit_vector(position, seed);
        if (near_zero(radiate_direction))
            radiate_direction = rec.normal;
        
        radiated = Ray(rec.p, radiate_direction);
        attenuation = albedo;
        return true;
    }
    
public:
    float3 albedo; //color
    float intensity;
};

class RTScene {
public:
    RTScene(thread Metal* metal_center,
            thread Irradiator* light1,
            thread Irradiator* light2,
            thread Irradiator* light3,
            thread Irradiator* light4,
            thread Irradiator* light5,
            float gameTime) {
        // this constructor is making the default scene for debugging
        objects[0] = Sphere(float3(0, 0, 0),   0.6, metal_center);
        objects[1] = Sphere(float3(cos(gameTime+1)*2,     cos(gameTime),         sin(gameTime)*2), 0.1, light1);
        objects[2] = Sphere(float3(cos(gameTime+3)*2,     sin(gameTime),         sin(gameTime+3)*2), 0.1, light2);
        objects[3] = Sphere(float3(cos(gameTime+2.2)*1.7, sin(-gameTime),        sin(gameTime+1)*2), 0.1, light3);
        objects[4] = Sphere(float3(cos(gameTime+1.5)*2.2, 0.9, sin(gameTime)*2), 0.1, light4);
        objects[5] = Sphere(float3(cos(-gameTime-1)*1.1,  cos(gameTime*2),       sin(-gameTime-1)), 0.1, light5);
        objects_len = 6;
    }
    
    
    RTScene(thread Sphere objects[], int len) {
        objects = objects;
        objects_len = len;
    }
    
    void add(thread Sphere& object) {
        objects[objects_len] = object;
        objects_len += 1;
    }
    
    bool intersect(thread const Ray& r, thread const float t_min, thread const float t_max, thread HitRecord& rec) {
        HitRecord temp_rec;
        bool hit_anything = false;
        float closest_so_far = t_max;
        
        for (int i = 0; i < objects_len; i++) {
            if (objects[i].intersect(r, t_min, closest_so_far, temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec = temp_rec;
            }
        }
        return hit_anything;
    }
    
public:
    Sphere objects[6]; // scene spheres
    int objects_len;
};

float3 tracing(thread const Ray& ray, thread RTScene& scene, float depth, float image_width, float image_height, thread const uint2& position, float seed) {
    
    bool hasHit = false;
    
    Ray cur_ray = ray;
    float3 cur_attenuation = float3(1.0f);
    
    for(int i = 0; i < depth; i++) {
        HitRecord rec;
        if (scene.intersect(cur_ray, 0.001, FLT_MAX, rec)) {
            hasHit = true;
            if (rec.mat_id == 1) { // Lambertian
                Ray radiated;
                float3 attenuation;
                if(rec.lam_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+1)) {
                    cur_attenuation *= attenuation;
                    cur_ray = radiated;
                } else {
                    return float3(0.0,0.0,0.0);
                }
            }else if (rec.mat_id == 2) { // Metal
                Ray radiated;
                float3 attenuation;
                if(rec.met_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+2)) {
                    cur_attenuation *= attenuation;
                    cur_ray = radiated;
                } else {
                    return float3(0.0,0.0,0.0);
                }
            } else if (rec.mat_id == 4) {
                Ray radiated;
                float3 attenuation;
                if(rec.irr_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+4)) {
                    cur_attenuation *= attenuation;
                    cur_attenuation *= rec.irr_mat_ptr->intensity;
                    cur_ray = radiated;
                } else {
                    return float3(0.0,0.0,0.0);
                }
            }
        } else {
            if (hasHit == true) {
                float3 unit_direction = unit_vector(cur_ray.direction());
                float t = 0.5f*(unit_direction.y + 1.0f);
                float3 c = (1.0f-t)*float3(1.0, 1.0, 1.0) + t*float3(0.5, 0.7, 1.0); //蓝天
                //c *= 0; //make the scene brighter
                return cur_attenuation * c;
            } else {
                return float3(0.001f);
            }
        }
    }
    return float3(0.001f); // exceeded recursion
}

// debug the shaders
// https://developer.apple.com/documentation/metal/shader_authoring/developing_and_debugging_metal_shaders
// thread group(apple developer)
// https://developer.apple.com/documentation/metal/creating_threads_and_threadgroups
kernel void draw_pixel_func(texture2d<float, access::write> drawable [[ texture(0) ]],
                            constant  RenderConfig          &rc      [[ buffer(0) ]],
                            const     uint2                 position [[thread_position_in_grid]]) {
    
    Metal metal_center(float3(0.7, 0.6,  0.5),  0);
    Irradiator light1(float3(0.87, 0.27, 0.24), 2);
    Irradiator light2(float3(0.91, 0.71, 0.26), 2);
    Irradiator light3(float3(0.47, 0.79, 0.29), 2);
    Irradiator light4(float3(0.29, 0.57, 0.85), 2);
    Irradiator light5(float3(0.52, 0.29, 0.94), 2);
    
    thread RTScene scene(&metal_center,
                         &light1,
                         &light2,
                         &light3,
                         &light4,
                         &light5,
                         rc.gameTime);
    
    int j_index = position.y;
    int i_index = position.x;
    
    float3 pixelColor = float3(0, 0, 0);
    
    Camera cam(rc.lookfrom, rc.lookat, rc.vup, rc.vfov, rc.aspectRatio);
    
    for (int i = 0; i < rc.samples_per_pixel; i++) {
        float u = (i_index + randomer_gen_float(position, rc.tickSeed+i)) / (rc.imageWidth-1);
        float v = (rc.imageHeight - j_index + randomer_gen_float(position, rc.tickSeed+i+1)) / (rc.imageHeight-1); //(rc.imageHeight - j_index) -> flipping image horizontally
        Ray ray = cam.get_ray(u, v);
        pixelColor += tracing(ray, scene, rc.max_depth, rc.imageWidth, rc.imageHeight, position, rc.tickSeed+i+2);
    }
    
    float scale = 1.0 / rc.samples_per_pixel;
    
    // gamma-correct for gamma=2.0. (look weird on mac's screen, I just use my own way...)
    // clamp & translated [0,1] value
    float4 drawableColor = float4(clamp(scale * pixelColor.x, 0.0, 0.999),
                                  clamp(scale * pixelColor.y, 0.0, 0.999),
                                  clamp(scale * pixelColor.z, 0.0, 0.999),
                                  1.0);
    
    drawable.write(drawableColor, uint2(position.x*2, position.y*2));
    drawable.write(drawableColor, uint2(position.x*2, position.y*2+1));
    drawable.write(drawableColor, uint2(position.x*2+1, position.y*2));
    drawable.write(drawableColor, uint2(position.x*2+1, position.y*2+1));
}

