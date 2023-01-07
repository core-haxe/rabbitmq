package rabbitmq.impl;

import promises.Promise;

using StringTools;

class MessageBase {
    public var channel:Channel;
    public var content:MessageContent;
    public var options:MessageOptions;

    public function new(?content:MessageContent, ?headers:Map<String, Any>, ?options:MessageOptions) {
        this.content = content;
        this.headers = headers;
        this.options = options;
    }

    public function ack():Promise<RabbitMQResult<Bool>> {
        return channel.ack(cast(this, Message));
    }

    public function nack():Promise<RabbitMQResult<Bool>> {
        return channel.nack(cast(this, Message));
    }

    private var _headers:Map<String, Any> = null;
    public var headers(get, set):Map<String, Any>;
    private function get_headers():Map<String, Any> {
        return _headers;
    }
    private function set_headers(value:Map<String, Any>):Map<String, Any> {
        _headers = value;
        return value;
    }

    public var properties(get, null):Map<String, Any>;
    private function get_properties():Map<String, Any> {
        return null;
    }

    public function headersToObject():Dynamic {
        if (_headers == null) {
            return null;
        }
        var o:Dynamic = {};

        for (k in _headers.keys()) {
            var v = _headers.get(k);
            Reflect.setField(o, k, v);
        }
        return o;
    }

    public function clone():Message {
        var c = new Message();
        c.content = this.content;
        c.options = this.options;
        if (this._headers != null) {
            for (k in this._headers.keys()) {
                if (k.startsWith("x-")) {
                    continue;
                }

                if (c._headers == null) {
                    c._headers = [];
                }
                c._headers.set(k, this._headers.get(k));
            }
        }
        return c;
    }
}