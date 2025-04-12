package rabbitmq;

#if nodejs

typedef Message = rabbitmq.impl.nodejs.Message;

#elseif php

typedef Message = rabbitmq.impl.php.Message;

#else

typedef Message = rabbitmq.impl.fallback.Message;

#end
