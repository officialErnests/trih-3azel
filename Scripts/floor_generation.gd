extends MeshInstance3D

@export var floor_size: int

func _ready() -> void:
	gen_floor()

func gen_floor():
	var surface_array = []
	surface_array.resize(Mesh.ARRAY_MAX)

	# PackedVector**Arrays for mesh construction.
	var verts = PackedVector3Array()
	var uvs = PackedVector2Array()
	var normals = PackedVector3Array()
	var indices = PackedInt32Array()

	var index := 0
	for r in range(floor_size):
		for x in range(r + 1):
			index += 1
			verts.append(Vector3(x, r, 0))
			normals.append(Vector3.DOWN)
			uvs.append(Vector2(x / float(floor_size) + 1, r / float(floor_size)))
		for y in range(r):
			index += 1
			verts.append(Vector3(r, y, 0))
			normals.append(Vector3.DOWN)
			uvs.append(Vector2(r / float(floor_size), y / float(floor_size)))
	print(verts)
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 1)
	
	indices.append(index)
	indices.append(index + 2)
	indices.append(index + 3)

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

#THX TO
#https://gamedev.net/blogs/entry/2277691-procedural-geometry-in-godot/
