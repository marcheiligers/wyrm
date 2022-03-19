Event = Struct.new(:name, :target) do
  def source
    target
  end

  def value
    target.value
  end
end

module Observable
  def observers
    @observers ||= {}
  end

  def attach_observer(observer, callback = :observe, &block)
    observers[observer] = block || callback
    self
  end

  def detach_observer(observer)
    observers.delete observer
    self
  end

  def notify_observers(event, private: false)
    observers.each do |observer, callback|
      if callback.is_a?(Proc)
        callback.call(event, observer)
      else
        observer.__send__(callback, event)
      end
    end
    $publisher.publish(event) unless private
    self
  end
end

class Publisher
  include Observable

  def publish(event)
    puts "Event #{event.name} from #{event.target.inspect}" if $state.debug
    notify_observers(event, private: true)
  end
end

$publisher = Publisher.new
