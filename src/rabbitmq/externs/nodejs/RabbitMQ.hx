package rabbitmq.externs.nodejs;

import js.lib.Error;

@:jsRequire("amqplib/callback_api")
extern class RabbitMQ {
    public static function connect(host:String, callback:Error->Connection->Void):Void;
}