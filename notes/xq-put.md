
```
# xq put {data-path}
xq put example.com/usecase/employees.xml'
```

all *data* sources are located in the "./src/data/" directory so 
the resolved source file will be ./src/data/example.com/usecase/employees.xml

{data-path} consists of {domain}/{path}
The {domain} part will resolve as the xqerl database name

