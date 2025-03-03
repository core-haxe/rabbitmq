package rabbitmq.impl;

import promises.Promise;

class ConnectionBase {
    public var url:String;

    private var _listeners:Map<String, Array<Any->Connection->Void>> = [];

    public function new(url:String) {
        this.url = url;
    }

    public function listenFor(event:String, callback:Any->Connection->Void) {
        var list = _listeners.get(event);
        if (list == null) {
            list = [];
            _listeners.set(event, list);
        }
        list.push(callback);
    }

    public function unlistenFor(event:String, callback:Any->Connection->Void) {
        var list = _listeners.get(event);
        if (list != null) {
            list.remove(callback);
        }
    }

    private function dispatchListeners(event:String, param:Any) {
        var list = _listeners.get(event);
        if (list != null) {
            for (l in list) {
                l(param, cast this);
            }
        }
    }

    public function connect():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::connect" not implemented'));
        });
    }

    public function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::close" not implemented'));
        });
    }

    public function createChannel(confirmationChannel:Bool = false):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::createChannel" not implemented'));
        });
    }
}