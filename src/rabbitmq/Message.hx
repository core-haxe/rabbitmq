package rabbitmq;

#if nodejs

typedef Message = rabbitmq.impl.nodejs.Message;

#else

typedef Message = rabbitmq.impl.fallback.Message;

#end
