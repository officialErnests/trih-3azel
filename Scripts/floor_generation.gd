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

	_add_quad(Transform3D(
		Basis.looking_at(Vector3.UP, Vector3.BACK) * 2,
		Vector3(1, 0, 0)
	), verts, uvs, normals, indices)

	# Assign arrays to surface array.
	surface_array[Mesh.ARRAY_VERTEX] = verts
	surface_array[Mesh.ARRAY_TEX_UV] = uvs
	surface_array[Mesh.ARRAY_NORMAL] = normals
	surface_array[Mesh.ARRAY_INDEX] = indices

	# Create mesh surface from mesh array.
	# No blendshapes, lods, or compression used.
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)

#https://gamedev.net/blogs/entry/2277691-procedural-geometry-in-godot/
func _add_quad(xform: Transform3D, verts: PackedVector3Array, uvs: PackedVector2Array, normals: PackedVector3Array, triangles: PackedInt32Array) -> void:
	var index := verts.size()
	
	# corners before transforming
	var vert1 := Vector3(-.5, -.5, 0)
	var vert2 := Vector3(-.5, .5, 0)
	var vert3 := Vector3(.5, .5, 0)
	var vert4 := Vector3(.5, -.5, 0)
	
	verts.append(xform * vert1)
	verts.append(xform * vert2)
	verts.append(xform * vert3)
	verts.append(xform * vert4)
	
	uvs.append(Vector2(1, 0))
	uvs.append(Vector2(1, 1))
	uvs.append(Vector2(0, 1))
	uvs.append(Vector2(0, 0))
	
	var normal := xform * Vector3.FORWARD;
	normals.append(normal)
	normals.append(normal)
	normals.append(normal)
	normals.append(normal)
	
	triangles.append(index + 2)
	triangles.append(index + 1)
	triangles.append(index)
	
	triangles.append(index + 3)
	triangles.append(index + 2)
	triangles.append(index)
