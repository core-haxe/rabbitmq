package rabbitmq.impl.php;

import phpAmqpLib.message.AMQPMessage;
import haxe.io.Bytes;
import phpAmqpLib.channel.AMQPChannel;
import promises.Promise;

class Exchange extends ExchangeBase {
    public override function create(?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var passive = false;
                var durable = false;
                var auto_delete = false;
                var internal = false;
                var nowait = false;
                var arguments = [];
                if (options != null) {
                    if (options.durable != null) durable = options.durable;
                    if (options.autoDelete != null) auto_delete = options.autoDelete;
                    if (options.internal != null) internal = options.internal;
                    if (options.arguments != null) arguments = options.arguments;
                }
                var result = nativeChannel.exchange_declare(this.name, this.type, passive, durable, auto_delete, internal, nowait, arguments);
                resolve(new RabbitMQResult(channel.connection, true, channel, this));
            } catch (e:Dynamic) {
                reject(new RabbitMQError(e, e));
            }
        });
    }

    public override function createBoundQueue(?name:String, ?options:QueueOptions, ?pattern:String):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var queue = new Queue(this.channel, name);
            queue.create(options).then(_ -> {
                var routing_key = '';
                var nowait = false;
                var arguments = null;
                nativeChannel.queue_bind(queue.name, this.name, routing_key, nowait);
                resolve(new RabbitMQResult(channel.connection, true, channel, this, queue));
            }, error -> {
                reject(error);
            });
        });
    }

    public override function publish(message:Message, ?routingKey:String, ?options:PublishOptions):Promise<RabbitMQResult<Message>> {
        return new Promise((resolve, reject) -> {
            try {
                if (routingKey == null) {
                    routingKey = "";
                }

                var messageContent:Bytes = message.content;
                var nativeMessage = new AMQPMessage(messageContent);
                nativeChannel.basic_publish(nativeMessage, this.name, routingKey);

                resolve(new RabbitMQResult(channel.connection, message, channel, this));
            } catch (e:Dynamic) {
                reject(e);
            }
        });
    }

    private var nativeChannel(get, null):AMQPChannel;
    private function get_nativeChannel():AMQPChannel {
        return @:privateAccess cast(channel, Channel)._nativeChannel;
    }
}