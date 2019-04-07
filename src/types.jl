"""
    type Coord

An {x,y,z} coordinate type. Used throughout the ConstructiveSolidGeometry.jl package for speed.

# Constructors
* `Coord(x::Float64, y::Float64, z::Float64)`
"""
type Coord
    x::Float64
    y::Float64
    z::Float64
end

"""
    type Ray

A ray is defined by its origin and a unitized direction vector

# Constructors
* `Ray(origin::Coord, direction::Coord)`
"""
type Ray
    origin::Coord
    direction::Coord
end

"""
    abstract Surface

An abstract class that all surfaces (`Sphere`, `Plane`, `InfCylinder`) inherit from. Implementation of new shapes should inherit from `Surface`.
"""
abstract type Surface end

"""
    type Plane <: Surface

Defined by a point on the surface of the plane, its unit normal vector, and an optional boundary condition.

# Constructors
* `Plane(point::Coord, normal::Coord)`
* `Plane(point::Coord, normal::Coord, boundary::String)`

# Arguments
* `point::Coord`: Any point on the surface of the plane
* `normal::Coord`: A unit normal vector of the plane. Recommended to use `unitize(c::Coord)` if normalizing is needed.
* `boundary::String`: Optional boundary condition, defined as a `String`. Options are "transmission" (default), "vacuum", and "reflective".
"""
type Plane <: Surface
    point::Coord
    normal::Coord
    reflective::Bool
	vacuum::Bool
	Plane(point::Coord, normal::Coord, ref::Bool, vac::Bool) = new(point, normal, ref, vac)
	function Plane(point::Coord, normal::Coord, boundary::String)
		if boundary == "reflective"
			new(point, normal, true, false)
		elseif boundary == "vacuum"
			new(point, normal, false, true)
		else
			new(point, normal, false, false)
		end
	end
	Plane(point::Coord, normal::Coord) = new(point, normal, false, false)
end

"""
    type Cone <: Surface

Defined by the tip of the cone, its direction axis vector, the angle between the central axis and the cone surface, and an optional boundary condition.

# Constructors
* `Cone(tip::Coord, axis::Coord, theta::Float64)`
* `Cone(tip::Coord, axis::Coord, theta::Float64, boundary::String)`

# Arguments
* `tip::Coord`: The vertex (tip) of the cone
* `axis::Coord`: A unit vector representing the central axis of the cone. As the cone equation actually defines two cones eminating in a mirrored fashion from the tip, this direction vector also indicates which cone is the true cone. I.e., following the direction of the axis vector when starting from the tip should lead inside the cone you actually want.  Recommended to use `unitize(c::Coord)` if normalizing is needed.
* `theta::Float64`: The angle (in radians) between the central axis (must be between 0 and pi/2)
* `boundary::String`: Optional boundary condition, defined as a `String`. Options are \"transmission\" (default) or \"vacuum\".
"""
type Cone <: Surface
    tip::Coord
    axis::Coord
	theta::Float64
    reflective::Bool
	vacuum::Bool
	Cone(tip::Coord, axis::Coord, theta::Float64, ref::Bool, vac::Bool) = new(tip, axis, theta, ref, vac)
	function Cone(tip::Coord, axis::Coord, theta::Float64, boundary::String)
		if boundary == "reflective"
			new(tip, axis, theta, true, false)
		elseif boundary == "vacuum"
			new(tip, axis, theta, false, true)
		else
			new(tip, axis, theta, false, false)
		end
	end
	Cone(tip::Coord, axis::Coord, theta::Float64) = new(tip, axis, theta, false, false)
end

"""
    type Sphere <: Surface

Defined by the center of the sphere, its radius, and an optional boundary condition.

# Constructors
* `Sphere(center::Coord, radius::Float64)`
* `Sphere(center::Coord, radius::Float64, boundary::String)`

# Arguments
* `center::Coord`: The center of the sphere
* `radius::Float64`: The radius of the sphere
* `boundary::String`: Optional boundary condition, defined as a `String`. Options are \"transmission\" (default) or \"vacuum\".
"""
type Sphere <: Surface
    center::Coord
    radius::Float64
    reflective::Bool
	vacuum::Bool
	Sphere(c::Coord, r::Float64, ref::Bool, vac::Bool) = new(c, r, ref, vac)
	function Sphere(c::Coord, r::Float64, boundary::String)
		if boundary == "reflective"
			new(c, r, true, false)
		elseif boundary == "vacuum"
			new(c, r, false, true)
		else
			new(c, r, false, false)
		end
	end
	Sphere(c::Coord, r::Float64) = new(c, r, false, false)
end

"""
    type InfCylinder <: Surface

An arbitrary direction infinite cylinder defined by any point on its central axis, its radius, the unit normal direction of the cylinder, and an optional boundary condition. A finite cylinder can be generated by defining the intersection of an infinite cylinder and two planes.

# Constructors
* `InfCylinder(center::Coord, normal::Coord, radius::Float64)`
* `InfCylinder(center::Coord, normal::Coord, radius::Float64, boundary::String)`

# Arguments
* `center::Coord`: The center of the infinite cylinder
* `normal::Coord`: A unit normal direction vector of the cylinder (i.e., a vector along its central axis), Recommended to use `unitize(c::Coord)` if normalizing is needed.
* `radius::Float64`: The radius of the infinite cylinder
* `boundary::String`: Optional boundary condition, defined as a `String`. Options are \"transmission\" (default) or \"vacuum\".
"""
type InfCylinder <: Surface
    center::Coord
    normal::Coord
    radius::Float64
    reflective::Bool
	vacuum::Bool
	InfCylinder(c::Coord, n::Coord, r::Float64, ref::Bool, vac::Bool) = new(c, n, r, ref, vac)
	function InfCylinder(c::Coord, n::Coord, r::Float64, boundary::String)
		if boundary == "reflective"
			new(c, n, r, true, false)
		elseif boundary == "vacuum"
			new(c, n, r, false, true)
		else
			new(c, n, r, false, false)
		end
	end
	InfCylinder(c::Coord, n::Coord, r::Float64) = new(c, n, r, false, false)
end

"""
    type Box

An axis aligned box is defined by the minimum `Coord` and maximum `Coord` of the box. Note that a Box is only used by ConstructiveSolidGeometry.jl for bounding box purposes, and is not a valid surface to define CSG cells with. Instead, you must define all six planes of a box independently.

# Constructors
* `Box(min::Coord, max::Coord)`
"""
type Box
    lower_left::Coord
    upper_right::Coord
end

"""
    type Region

The volume that is defined by a surface and one of its halfspaces

# Constructors
* `Region(surface::Surface, halfspace::Int64)`

# Arguments
* `surface::Surface`: A `Sphere`, `Plane`, or `InfCylinder`
* `halfspace::Int64`: Either +1 or -1
"""
type Region
    surface::Surface
    halfspace::Int64
end

"""
    type Cell

Defined by an array of regions and the logical combination of those regions that define the cell

# Constructors
* `Cell(regions::Array{Region}, definition::Expr)`

# Arguments
* `regions::Array{Region}`: An array of regions that are used to define the cell
* `definition::Expr`: A logical expression that defines the volume of the cell. The intersection operator is ^, the union operator is |, and the complement operator is ~. Regions are defined by their integer indices in the regions array.
"""
type Cell
    regions::Array{Region}
    definition::Expr
end

"""
    type Geometry

The top level object that holds all the cells in the problem. This object contains all data regarding the geometry within a system.

# Constructors
* `Geometry(cells::Array{Cell}, bounding_box::Box)`

# Arguments
* `cells::Array{Cell}`: All cells inside the geometry. The cells must combine to fill the entire space of the bounding box. No two cells should overlap.
* `bounding_box::Box`: The bounding box around the problem.
"""
type Geometry
    cells::Array{Cell}
    bounding_box::Box
end

_p = Coord(0,0,0)
typeassert(_p, Coord)