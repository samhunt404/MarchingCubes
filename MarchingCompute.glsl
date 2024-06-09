#[compute]
#version 450

//size of execution
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

//input grid size
layout(set = 0, binding = 0, std430) restrict buffer GridBuffer{
    float scalars[];
}
grid_buffer;

//output buffer vertices
layout(set = 0, binding = 1, std430) restrict buffer VertexBuffer {
    vec3 vertices[];
}
vertex_buffer;

// The code we want to execute in each invocation
void main() {
    vertex_buffer.vertices[gl_GlobalInvocationID.x] = vec3(0.1,0.1,0.1);
}