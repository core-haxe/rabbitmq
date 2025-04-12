package rabbitmq;

#if nodejs

typedef Queue = rabbitmq.impl.nodejs.Queue;

#elseif php

typedef Queue = rabbitmq.impl.php.Queue;

#else

typedef Queue = rabbitmq.impl.fallback.Queue;

#end