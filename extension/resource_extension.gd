class_name REsource
extends Resource

static func ensure(resource: Resource, type) -> Resource:
	if not resource is type:
		assert(false, 'resource must be of given type')
		return null
	return resource
