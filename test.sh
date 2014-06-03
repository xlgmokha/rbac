#!/bin/bash -x

curl -X POST -d "name=mo&roles=admin" http://localhost:3333/users
echo ""

curl -X POST -d "name=/litterbox&roles=admin" http://localhost:3333/resources
echo ""

curl -H "X-User: mo" http://localhost:9292/litterbox
echo ""

curl -H "X-User: eve" http://localhost:9292/litterbox
echo ""
