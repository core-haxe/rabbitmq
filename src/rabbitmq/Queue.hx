package rabbitmq;

#if nodejs

typedef Queue = rabbitmq.impl.nodejs.Queue;

#else

typedef Queue = rabbitmq.impl.fallback.Queue;

#end