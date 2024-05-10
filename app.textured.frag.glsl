#version 300 es

#define MAX_LIGHTS 16

precision mediump float;

uniform bool u_show_normals;

struct AmbientLight {
    vec3 color;
    float intensity;
};

struct DirectionalLight {
    vec3 direction;
    vec3 color;
    float intensity;
};

struct PointLight {
    vec3 position;
    vec3 color;
    float intensity;
};

struct Material {
    vec3 kA;
    vec3 kD;
    vec3 kS;
    float shininess;
    sampler2D map_kD;
    sampler2D map_nS;
    sampler2D map_norm;
};

// Lights and materials
uniform AmbientLight u_lights_ambient[MAX_LIGHTS];
uniform DirectionalLight u_lights_directional[MAX_LIGHTS];
uniform PointLight u_lights_point[MAX_LIGHTS];

uniform Material u_material;

// Camera position in world space
uniform vec3 u_eye;

// With WebGL2, we now have to define an out that will be the color of the fragment
out vec4 o_fragColor;

// Received from vertex stage
in vec2 texture_coords;
in mat3 tbn_matrix;
in vec3 vertex_pos;

// Shades an ambient light and returns this light's contribution
vec3 shadeAmbientLight(Material material, AmbientLight light) {
    if (light.intensity == 0.0)
        return vec3(0);

    return light.color * light.intensity * material.kA * vec3(texture(material.map_kD, texture_coords));
}

// Shades a directional light and returns its contribution
vec3 shadeDirectionalLight(Material material, DirectionalLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    vec3 result = vec3(0);
    if (light.intensity == 0.0)
        return result;

    vec3 N = normalize(normal);
    vec3 L = -normalize(light.direction);
    vec3 V = normalize(vertex_position - eye);

    // Diffuse
    float LN = max(dot(L, N), 0.0);
    result += LN * light.color * light.intensity * material.kD * vec3(texture(material.map_kD, texture_coords));

    // Specular
    vec3 R = reflect(L, N);
    result += pow( max(dot(R, V), 0.0), material.shininess * texture(material.map_nS, texture_coords).x) * light.color * light.intensity * material.kS;


    return result;
}

// Shades a point light and returns its contribution
vec3 shadePointLight(Material material, PointLight light, vec3 normal, vec3 eye, vec3 vertex_position) {
    vec3 result = vec3(0);
    if (light.intensity == 0.0)
        return result;

    vec3 N = normalize(normal);
    float D = distance(light.position, vertex_position);
    vec3 L = normalize(light.position - vertex_position);
    vec3 V = normalize(vertex_position - eye);

    // vec3 lightContrib = (light.color * light.intensity * (1.0/(pow(distance(vertex_position.xyz, light.position.xyz), 2.0)+1.0)));

    // Diffuse
    float LN = max(dot(L, N), 0.0);
    result += LN * light.color * light.intensity * material.kD * vec3(texture(material.map_kD, texture_coords));

    // Specular
    vec3 R = reflect(L, N);
    result += pow( max(dot(R, V), 0.0), material.shininess * texture(material.map_nS, texture_coords).x) * light.color * light.intensity * material.kS;

    // Attenuation
    result *= 1.0 / (D*D+1.0);

    return result;
}

void main() {

    // Calculate the normal from the normal map and tbn matrix to get the world normal
    vec3 normal = vec3(texture(u_material.map_norm, texture_coords));
    normal = normal * 2.0 - 1.0;
    normal = normalize(tbn_matrix * normal);

    // If we only want to visualize the normals, no further computations are needed
    if (u_show_normals == true) {
        o_fragColor = vec4(normal, 1.0);
        return;
    }

    // We start at 0.0 contribution for this vertex
    vec3 light_contribution = vec3(0.0);

    // Iterate over all possible lights and add their contribution
    for(int i = 0; i < MAX_LIGHTS; i++) {
        light_contribution += shadeAmbientLight(u_material, u_lights_ambient[i]);
        light_contribution += shadeDirectionalLight(u_material, u_lights_directional[i], normal, u_eye, vertex_pos);
        light_contribution += shadePointLight(u_material, u_lights_point[i], normal, u_eye, vertex_pos);
    }

    o_fragColor = vec4(light_contribution, 1.0);
}