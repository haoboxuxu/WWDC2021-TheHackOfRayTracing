public let rtShaderNight = """
//
//  rtShaderNight.metal
//  MTKRenderLoop
//
//  Created by 徐浩博 on 2021/4/10.
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
class SkyBox;

struct HitRecord {
    float3 p;      //point3
    float3 normal; //vec3
    thread Lambertian* lam_mat_ptr;
    thread Metal* met_mat_ptr;
    thread Dielectric* die_mat_ptr;
    thread Irradiator* irr_mat_ptr;
    thread SkyBox* sb_mat_ptr;
    int mat_id; /* 1-Lambertian 2-Metal 3-Dielectric 4-Irradiator 5-SkyBox */
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
    Sphere(float3 cen, float r, thread SkyBox* sb) : center(cen), radius(r), sb_mat_ptr(sb) { mat_id = 5; };
    
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
        if (mat_id == 5) {
            rec.normal = -rec.normal;
        }
        // make use to copy all the material
        rec.lam_mat_ptr = lam_mat_ptr;
        rec.met_mat_ptr = met_mat_ptr;
        rec.die_mat_ptr = die_mat_ptr;
        rec.irr_mat_ptr = irr_mat_ptr;
        rec.sb_mat_ptr = sb_mat_ptr;
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
    thread SkyBox* sb_mat_ptr;
    int mat_id; /* 1-Lambertian 2-Metal 3-Dielectric 4-Irradiator 5-SkyBox */
};

class Camera {
public:
    Camera(float3 lookfrom,
           float3 lookat,
           float3 vup,
           float vfov, // vertical field-of-view in degrees
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

class Dielectric {
public:
    Dielectric(float index_of_refraction) : ir(index_of_refraction) {}
    
    bool radiate(thread const Ray& r_in,
                 thread const HitRecord& rec,
                 thread float3& attenuation,
                 thread Ray& radiated,
                 thread const uint2& position, float seed) const {
        attenuation = float3(1.0, 1.0, 1.0);
        float refraction_ratio = rec.front_face ? (1.0/ir) : ir;
        
        float3 unit_direction = unit_vector(r_in.direction());
        float cos_theta = fmin(dot(-unit_direction, rec.normal), 1.0);
        float sin_theta = sqrt(1.0 - cos_theta*cos_theta);
        
        bool cannot_refract = refraction_ratio * sin_theta > 1.0;
        float3 direction;
        
        if (cannot_refract || reflectance(cos_theta, refraction_ratio) > randomer_gen_float(position, seed))
            direction = reflect(unit_direction, rec.normal);
        else
            direction = refract(unit_direction, rec.normal, refraction_ratio);
        
        radiated = Ray(rec.p, direction);
        return true;
    }
    
public:
    float ir; //Refraction
private:
    static float reflectance(float cosine, float ref_idx) {
        auto r0 = (1-ref_idx) / (1+ref_idx);
        r0 = r0*r0;
        return r0 + (1-r0)*pow((1 - cosine),5);
    }
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
        float3 reflected = reflect(unit_vector(r_in.direction()), rec.normal);
        radiated = Ray(rec.p, reflected);
                       
        attenuation = albedo;
        return (dot(radiated.direction(), rec.normal) > 0);
    }
    
public:
    float3 albedo; //color
    float intensity;
};

class SkyBox {
public:
    SkyBox() {}
    
    bool radiate(thread const Ray& r_in,
                 thread const HitRecord& rec,
                 thread float3& attenuation,
                 thread Ray& radiated,
                 thread const uint2& position, float seed) const {
        float3 unit_direction = unit_vector(r_in.direction());
        float t = 0.9f*(unit_direction.y + 1.0f);
        float3 c = (1.0f-t)*float3(0.53, 0.5, 0.4) + t*float3(0.05, 0.05, 0.05); // space background
        float gradient = 4;
        float rd = pow(randomer_gen_float(uint2(gradient*abs(rec.p.x), gradient*abs(rec.p.y)), gradient*abs(rec.p.x+rec.p.y+rec.p.z)), 1000);
        float3 star = float3(rd, rd, rd-0.01);
        float3 reflected = reflect(unit_vector(r_in.direction()), rec.normal);
        radiated = Ray(rec.p, reflected);
        attenuation = star + c;
        attenuation *= 2.5;
        return (dot(radiated.direction(), rec.normal) < 0);
    }
};

class RTScene {
public:
    RTScene(thread Metal* ground,
            thread Metal* metal_center,
            thread Dielectric* glass,
            thread Irradiator* metal_ball,
            thread SkyBox* sb,
            float3 metalSpeherPos,
            float gameTime) {
        // this constructor is making the default scene for debugging
        //objects[0] = Sphere(float3(0,-1000,0), 1000, ground);
        objects[0] = Sphere(float3(0,-500, 0), 500, ground);
        objects[1] = Sphere(float3(0,   1, 0),   1,  glass);
        // make the radius slightly larger to touch the ground (simple pythagorean problem)
        objects[2] = Sphere(float3(0, 0.4, 2),   0.41, metal_center);
        objects[3] = Sphere(float3(cos(gameTime)*2, 1.5, sin(gameTime)*2),   0.2, metal_ball);
        objects[4] = Sphere(float3(0, 0, 0),   300, sb);
        objects_len = 5;
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
    Sphere objects[5]; // scene spheres
    int objects_len;
};

float3 tracing(thread const Ray& ray, thread RTScene& scene, float depth, float image_width, float image_height, thread const uint2& position, float seed) {
    
    Ray cur_ray = ray;
    float3 cur_attenuation = float3(1.0f);
    
    for(int i = 0; i < depth; i++) {
        HitRecord rec;
        if (scene.intersect(cur_ray, 0.001, FLT_MAX, rec)) {
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
            } else if (rec.mat_id == 3) { // Metal
                Ray radiated;
                float3 attenuation;
                if(rec.die_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+3)) {
                    cur_attenuation *= attenuation;
                    cur_ray = radiated;
                } else {
                    return float3(0.0,0.0,0.0);
                }
            } else if (rec.mat_id == 4) { // Irradiator
                Ray radiated;
                float3 attenuation;
                if(rec.irr_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+4)) {
                    cur_attenuation *= attenuation;
                    cur_attenuation += float3(rec.irr_mat_ptr->intensity);
                    cur_ray = radiated;
                } else {
                    return float3(0.0,0.0,0.0);
                }
            } else if (rec.mat_id == 5) { // SkyBox
                Ray radiated;
                float3 attenuation;
                if(rec.sb_mat_ptr->radiate(cur_ray, rec, attenuation, radiated, position, seed+5)) {
                    cur_attenuation *= attenuation;
                    cur_ray = Ray(radiated.orig, -radiated.direction());
                } else {
                    return float3(0.0,0.0,0.0);
                }
            }
        } else {
            return cur_attenuation;
        }
    }
    return float3(0.0f); // exceeded recursion
}

// debug the shaders
// https://developer.apple.com/documentation/metal/shader_authoring/developing_and_debugging_metal_shaders
// thread group(apple developer)
// https://developer.apple.com/documentation/metal/creating_threads_and_threadgroups
kernel void draw_pixel_func(texture2d<float, access::write> drawable [[ texture(0) ]],
                            constant  RenderConfig          &rc      [[ buffer(0) ]],
                            const     uint2                 position [[thread_position_in_grid]]) {
    
    Metal ground(float3(0.8, 0.8, 0.8), 0); //0.1 is slow
    Metal metal_center(float3(0.9, 0.6, 0.1), 0.0);
    Irradiator litter_light(float3(0.8, 0.6, 0.2), 4);
    Dielectric glass(1.5);
    Metal metal_ball(float3(0.4, 0.8, 0.4), 0.2); //0.8, 0.6, 0.2 //float3(1, 1, 1)
    SkyBox sb;
    
    thread RTScene scene(&ground,
                         &metal_center,
                         &glass,
                         &litter_light,
                         &sb,
                         rc.spherePos,
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
    
    // Divide the color by the number of samples and gamma-correct for gamma=2.0.
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
"""
