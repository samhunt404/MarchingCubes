extends Node3D
const GROUP_SIZE = Vector3i(64,64,64)
func _ready():
	#create local RenderingDevice
	var rd := RenderingServer.create_local_rendering_device()
	#load shader
	var shader_file := load("res://MarchingCompute.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	var shader := rd.shader_create_from_spirv(shader_spirv)

	var input:= PackedFloat32Array([0,1,2,3,4,5,6,7,8,9,10,11,12])
	var input_bytes = input.to_byte_array()
	var dummyArray = Array([])
	dummyArray.resize(12)
	var output := PackedFloat32Array(dummyArray)
	var output_bytes = output.to_byte_array()
	
	var in_buffer := rd.storage_buffer_create(input_bytes.size(),input_bytes)
	var in_uniform := RDUniform.new()
	in_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	in_uniform.binding = 0 #this needs to match the binding in the glsl
	in_uniform.add_id(in_buffer)
	
	var out_buffer := rd.storage_buffer_create(output_bytes.size(),output_bytes)
	var out_uniform := RDUniform.new()
	out_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	out_uniform.binding = 1
	out_uniform.add_id(out_buffer)
	
	#last parameter needs to match the "set" in the shader
	var uniform_set:=rd.uniform_set_create([in_uniform,out_uniform],shader,0)
	
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list,pipeline)
	rd.compute_list_bind_uniform_set(compute_list,uniform_set,0)
	
	rd.compute_list_dispatch(compute_list, 12,1,1,)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	var shader_output_bytes := rd.buffer_get_data(out_buffer)
	var shader_out := shader_output_bytes.to_float32_array()
	var shader_out_vec := (Array(shader_out))
	shader_output_bytes.to_float32_array()
	print("Input ", input)
	print("Output", shader_out)
	print("OutputVec", shader_out_vec)
