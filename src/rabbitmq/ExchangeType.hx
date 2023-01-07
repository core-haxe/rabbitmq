package rabbitmq;

enum abstract ExchangeType(String) from String to String {
    var Default = "";
    var Direct = "direct";
    var Topic = "topic";
    var Headers = "headers";
    var FanOut = "fanout";
}