package rabbitmq;

import promises.Promise;

/*
This isnt part of the rabbitmq api, but its a useful messaging pattern to be
able to use without having to manually wire up all the parts. Example usage
at the bottom of the file
*/

typedef RetryableQueueOptions = {
    var connection:Connection;
    var queueName:String; // the name of the "main" queue
    var ?queueNameRetry:String; // the name of the "retry" queue (if not specified it will be the queueName and a "-retry" suffix)
    var ?queueTtl:Null<Int>; // this will be the queue ttl (default is no queue ttl), this is different from the message ttl - not that rabbitmq will pick the smallest ttl
    var ?exchangeName:String; // if you dont specific this, all the queues will be created on a new exchange (which is recommended)
    var ?producerOnly:Bool;
}

class RetryableQueue {
    public var options:RetryableQueueOptions = null;
    public var connection:Connection = null;
    public var exchange:Exchange = null;
    public var retryQueue:Queue = null;
    public var queue:Queue = null;

    public function new(options:RetryableQueueOptions) {
        this.options  = options;
    }

    public function start():Promise<RetryableQueue> {
        return new Promise((resolve, reject) -> {
            this.connection = options.connection;
            var queueName = options.queueName;
            var queueNameRetry = options.queueNameRetry;
            if (queueNameRetry == null) {
                queueNameRetry = options.queueName + "-retry";
            }
            var exchangeName = options.exchangeName;
            if (exchangeName == null) {
                exchangeName = options.queueName + "-exchange";
            }

            connection.createChannel(false).then(result -> {
                return result.channel.createExchange(exchangeName, ExchangeType.Direct, {durable: true});
            }).then(result -> {
                var arguments:Dynamic = {};
                Reflect.setField(arguments, "x-dead-letter-exchange", exchangeName);
                Reflect.setField(arguments, "x-dead-letter-routing-key", queueName);
                if (options.queueTtl != null) {
                    Reflect.setField(arguments, "x-message-ttl", options.queueTtl);
                }
                return result.exchange.createBoundQueue(queueNameRetry, {durable: true, arguments: arguments}, queueNameRetry);
            }).then(result -> {
                retryQueue = result.queue;
                return result.exchange.createBoundQueue(queueName, {durable: true}, queueName);
            }).then(result -> {
                exchange = result.exchange;
                queue = result.queue;
                if (!options.producerOnly) {
                    queue.onMessage = onMessageInternal;
                }
                resolve(this);
                return null;
            }, (error:RabbitMQError) -> {
                reject(error);
            });
        });
    }

    public function publish(message:Message) {
        exchange.publish(message, queue.name);
    }

    public function retry(message:Message, delay:Null<Int> = null) {
        if (delay == null) {
            delay = 0;
        }
        if (message.options == null) {
            message.options = {};
        }
        message.options.expiration = Std.string(delay);
        exchange.publish(message, retryQueue.name);
    }

    private function onMessageInternal(message:Message) {
        if (_onMessage != null) {
            _onMessage(message);
        } else {
            message.nack();
        }
    }

    private var _onMessage:Message->Void;
    public var onMessage(get, set):Message->Void;
    private function get_onMessage():Message->Void {
        return _onMessage;
    }
    private function set_onMessage(value:Message->Void):Message->Void {
        _onMessage = value;
        queue.startConsuming();
        return value;
    }

}

/*

        var connection = new Connection("amqp://localhost");
        connection.connect().then(result -> {
			var retryableQueue = new RetryableQueue({
				connection: result.connection,
				queueName: "my-test2"
			});
			return retryableQueue.start();
        }).then(retryableQueue -> {
			retryableQueue.onMessage = (message) -> {
				var now = Date.now().getTime();
				var content = message.content;
				var enqueTime = Std.parseFloat(content.toString());
				var delta = now - enqueTime;
				trace("got message", content, (delta / 1000) + "s", message.headers.get("foo"));

				message.ack();

				retryableQueue.retry(message.clone(), 1000);
			}

			var time = Date.now().getTime();
			var message = new Message("" + time, ["foo" => "bar"]);
			retryableQueue.publish(message);
			return null;
		}, (error:RabbitMQError) -> {
            connection.close();
            trace("!!!!!!!!!!!!!!!!!!!!! ERROR! ", error.name, error.message);
        });

*/