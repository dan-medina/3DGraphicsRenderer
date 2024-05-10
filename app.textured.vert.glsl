#version 300 es

// An attribute will receive data from a buffer
in vec3 a_position;
in vec3 a_normal;
in vec3 a_tangent;
in vec2 a_texture_coord;

// Transformation matrices
uniform mat4x4 u_m;
uniform mat4x4 u_v;
uniform mat4x4 u_p;

// Output to fragment stage
out vec2 texture_coords;
out mat3 tbn_matrix;
out vec3 vertex_pos;

void main() {

    // Transform a vertex from object space directly to screen space
    vec4 vertex_position_world = u_m * vec4(a_position, 1.0);

    vec3 normal = normalize(vec3(u_m * vec4(a_normal, 0.0)));
    vec3 tangent = normalize(vec3(u_m * vec4(a_tangent, 0.0)));

    tangent = normalize(tangent - dot(tangent, normal) * normal);
    vec3 bitangent = cross(normal, tangent);

    mat3 tbn = mat3(tangent, bitangent, normal);

    // Forward data to fragment stage
    texture_coords = a_texture_coord;
    vertex_pos = vec3(vertex_position_world);
    tbn_matrix = tbn;

    gl_Position = u_p * u_v * vertex_position_world;

}