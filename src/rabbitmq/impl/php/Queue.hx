package rabbitmq.impl.php;

import haxe.io.Bytes;
import phpAmqpLib.message.AMQPMessage;
import haxe.Timer;
import php.Syntax;
import php.NativeArray;
import php.NativeAssocArray;
import promises.Promise;
import phpAmqpLib.channel.AMQPChannel;
import phpAmqpLib.wire.AMQPTable;

class Queue extends QueueBase {

    public override function create(?options:QueueOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var passive = false;
                var durable = false;
                var exclusive = false;
                var auto_delete = false;
                var nowait = false;
                var arguments = new AMQPTable();
                if (options != null) {
                    if (options.exclusive != null) exclusive = options.exclusive;
                    if (options.durable != null) durable = options.durable;
                    if (options.autoDelete != null) auto_delete = options.autoDelete;
                    if (options.arguments != null) {
                        for (field in Reflect.fields(options.arguments)) {
                            arguments.set(field, Reflect.field(options.arguments, field));
                        }
                    }
                }
                var result = nativeChannel.queue_declare(this.name, passive, durable, exclusive, auto_delete, nowait, arguments);
                resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
            } catch (e:Dynamic) {
                reject(new RabbitMQError(e, e));
            }
        });
    }

    private var consumerTag:String = null;
    public override function startConsuming(?options:ConsumeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var consumer_tag = "";
                var no_local = false;
                var no_ack = false;
                var exclusive = false;
                var nowait = false;
                consumerTag = nativeChannel.basic_consume(this.name, consumer_tag, no_local, no_ack, exclusive, nowait, onNativeMessage);
                startPolling();
                resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
            } catch (e:Dynamic) {
                reject(new RabbitMQError(e, e));
            }
        });
    }

    private function startPolling() {
        poll();
    }

    private function poll() {
        if (nativeChannel.is_consuming()) {
            nativeChannel.wait(null, true);
            Timer.delay(poll, 10);
        }
    }

    private function onNativeMessage(nativeMessage:AMQPMessage) {
        var message = new Message(Bytes.ofString(nativeMessage.getBody()));
        message.channel = this.channel;
        message.nativeMessage = nativeMessage;
        if (_onMessage != null) {
            _onMessage(message);
        }
    }

    public override function stopConsuming():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (nativeChannel.is_consuming()) {
                nativeChannel.basic_cancel(consumerTag);
            }
            resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
        });
    }

    private var nativeChannel(get, null):AMQPChannel;
    private function get_nativeChannel():AMQPChannel {
        return @:privateAccess cast(channel, Channel)._nativeChannel;
    }
}