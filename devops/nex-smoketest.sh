#!/bin/bash

# DIR="${BASH_SOURCE%/*}"
# if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
# . "$DIR/nex-include.sh"

# to ensure if 1 command fails.. build fail
set -e

# ensure prefix is pass in
if [ $# -lt 1 ] ; then
	echo "NEX smoketest needs prefix"
	echo "nex-smoketest.sh acceptance"
	exit
fi

PREFIX=$1
APP_NAME=${PREFIX}-contractproposal

# check if doing local smoke test
if [ "${PREFIX}" = "local" ] ; then
  LOCAL_DEV=1
	PREFIX=$(echo $(hostname) | md5sum |cut -c -10)
	APP_NAME=${PREFIX}-contractproposal
else
	LOCAL_DEV=0
fi

# 1. Get App configuration via CF
if [ "${LOCAL_DEV}" -ne 1 ]; then
    echo "Server Deployment"

else
	STD_APP_URL="http://localhost:8000"

	echo "Local Development"
	echo STD_APP_URL=${STD_APP_URL}

fi

# Test: Create Products
echo "=== Creating a product id: the_odyssey ==="
curl -XPOST -d '{"id": "the_odyssey", "title": "The Odyssey", "passenger_capacity": 101, "maximum_speed": 5, "in_stock": 10}' 'http://localhost:8000/products'
echo
# Test: Get Product
echo "=== Getting product id: the_odyssey ==="
curl -s 'http://localhost:8000/products/the_odyssey' | jq .

# Test: Create Order
echo "=== Creating Order ==="
ORDER_ID=$(curl -s -XPOST -d '{"order_details": [{"product_id": "the_odyssey", "price": "100000.99", "quantity": 1}]}' 'http://localhost:8000/orders')
echo ${ORDER_ID}
ID=$(echo ${ORDER_ID} | jq '.id')

# Test: Get Order back
echo "=== Getting Order ==="
curl -s "http://localhost:8000/orders/${ID}" | jq -r

#Test: Delete Order with order_id
echo "====Deleting OrderDetails ======="
curl -s -X DELETE "http://localhost:8000/delete/order/${ID}" | jq -r

#Test: check the order after deletion
echo "=== Getting Order ==="
curl -s "http://localhost:8000/orders/${ID}" | jq -r

# Test: Get Product to check the stock
echo "=== Getting product id: the_odyssey and checking the stock ==="
curl -s 'http://localhost:8000/products/the_odyssey' | jq .

#Test: Delete the product by product id
echo "=============Deleting product by product id ==========="
curl -s 'http://localhost:8000/delete/product/the_odyssey' | jq -r

# Test: Get all available products 
echo "=== Getting all products ==="
curl -s 'http://localhost:8000/products' | jq .
