module StatelyObject
  attr_reader :me

  def initialize(namespace)
    @me = args.state[namespace] = args.state.new_entity(namespace)
  end

  def serialize
    me.as_hash.except(:entity_id, :entity_name, :entity_keys_by_ref, :entity_type, :created_at, :global_created_at)
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end 
end
