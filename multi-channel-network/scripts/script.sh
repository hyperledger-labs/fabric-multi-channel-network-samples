#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "MCN( Multi Channel Network ) end-to-end test"
echo
CHANNEL_NAME_PREFIX="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
: ${CHANNEL_NAME_PREFIX:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
#: ${VERBOSE:="false"}
: ${VERBOSE:="true"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=3

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

if [ "$LANGUAGE" = "java" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/java/"
fi

echo "Channel name prefix : "$CHANNEL_NAME_PREFIX

# import utils
. scripts/utils.sh

createChannel() {
	PEER=$1
	ORG=$2
	echo " ### [DEBUG] PEER=$PEER   ORG=$ORG   CHANNEL=$CHANNEL_NAME ###"

	setGlobals $PEER $ORG

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel '$CHANNEL_NAME' created ===================== "
	echo
}

joinChannel () {
	peer=$1
	org=$2
	
	#for org in 1 2; do
	    #for peer in 0 0; do
		#joinChannelWithRetry $peer $org
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined channel '$CHANNEL_NAME' ===================== "
		sleep $DELAY
		echo
	    #done
	#done
}

echo
echo "#########################"
echo "### Chaincode for ch1 ###"
echo "#########################"
echo

CHANNEL_NAME=${CHANNEL_NAME_PREFIX}1

## Create channel
echo "Creating channel1..."
createChannel 0 1

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel 0 1
joinChannel 0 2
joinChannel 0 3

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org1 in ch1..."
updateAnchorPeers 0 1
echo "Updating anchor peers for org2 in ch1..."
updateAnchorPeers 0 2
echo "Updating anchor peers for org3 in ch1..."
updateAnchorPeers 0 3

## Install chaincode on peer0.org1 and peer0.org2 and peer0.org3
echo "Install chaincode on peer0.org1..."
installChaincode 0 1
echo "Install chaincode on peer0.org2..."
installChaincode 0 2
echo "Install chaincode on peer0.org3..."
installChaincode 0 3

# Instantiate chaincode on peer0.org1
echo "Instantiating chaincode on peer0.org1 in ch1..."
instantiateChaincode 0 1 '{"Args":["init","a","1000","b","2000"]}' "'Org1MSP.peer','Org2MSP.peer','Org3MSP.peer'"

# Query chaincode on peer0.org1
echo "Querying chaincode on peer0.org1 in ch1..."
chaincodeQuery 0 1 a 1000

# Query chaincode on peer0.org2
echo "Querying chaincode on peer0.org2 in ch1..."
chaincodeQuery 0 2 a 1000

# Query chaincode on peer0.org3
echo "Querying chaincode on peer0.org3 in ch1..."
chaincodeQuery 0 3 a 1000

# Invoke chaincode on peer0.org1 and peer0.org2 peer0.org3
echo "Sending invoke transaction on peer0.org1 peer0.org2 peer0.org3 in ch1..."
chaincodeInvoke 0 1 0 2 0 3

# Query on chaincode on peer0.org1, check if the result is 90
echo "Querying chaincode on peer0.org1 in ch1..."
chaincodeQuery 0 1 a 990

# Query on chaincode on peer0.org2, check if the result is 90
echo "Querying chaincode on peer0.org2 in ch1..."
chaincodeQuery 0 2 a 990

# Query on chaincode on peer0.org3, check if the result is 90
echo "Querying chaincode on peer0.org3 in ch1..."
chaincodeQuery 0 3 a 990

# Query on chaincode on peer0.org1, check if the result is 90
echo "Querying chaincode on peer0.org1 in ch1..."
chaincodeQuery 0 1 b 2010

# Query on chaincode on peer0.org2, check if the result is 90
echo "Querying chaincode on peer0.org2 in ch1..."
chaincodeQuery 0 2 b 2010

# Query on chaincode on peer0.org3, check if the result is 90
echo "Querying chaincode on peer0.org3 in ch1..."
chaincodeQuery 0 3 b 2010

echo
echo "#########################"
echo "### Chaincode for ch2 ###"
echo "#########################"
echo

CHANNEL_NAME=${CHANNEL_NAME_PREFIX}2

## Create channel
echo "Creating channel2..."
createChannel 1 3

## Join all the peers to the channel
echo "Having all peers join the channel..."
joinChannel 1 3
joinChannel 0 4

## Set the anchor peers for each org in the channel
echo "Updating anchor peers for org3 in ch2.."
updateAnchorPeers 1 3
echo "Updating anchor peers for org4 in ch2.."
updateAnchorPeers 0 4

## Install chaincode on peer1.org3 and peer0.org4
echo "Install chaincode on peer1.org3..."
installChaincode 1 3
echo "Install chaincode on peer0.org4..."
installChaincode 0 4

# Instantiate chaincode on peer0.org3
echo "Instantiating chaincode on peer1.org3 in ch2..."
instantiateChaincode 1 3 '{"Args":["init","a","100","b","200"]}' "'Org3MSP.peer','Org4MSP.peer'"

# Query chaincode on peer1.org3
echo "Querying chaincode on peer1.org3 in ch2..."
chaincodeQuery 1 3 a 100

# Query chaincode on peer0.org4
echo "Querying chaincode on peer0.org4 in ch2..."``
chaincodeQuery 0 4 a 100

# Invoke chaincode on peer1.org3 and peer0.org4
echo "Sending invoke transaction on peer1.org3 peer0.org4 in ch2..."
chaincodeInvoke 1 3 0 4

# Query on chaincode on peer1.org3, check if the result a is 90
echo "Querying chaincode on peer1.org3 in ch2..."
chaincodeQuery 1 3 a 90

# Query on chaincode on peer0.org4, check if the result a is 90
echo "Querying chaincode on peer0.org4 in ch2..."
chaincodeQuery 0 4 a 90

# Query on chaincode on peer1.org3, check if the result b is 210
echo "Querying chaincode on peer0.org4 in ch2..."
chaincodeQuery 1 3 b 210

# Query on chaincode on peer0.org4, check if the result b is 210
echo "Querying chaincode on peer0.org4 in ch2..."
chaincodeQuery 0 4 b 210


echo
echo "========= All GOOD, MCN( Multi Channel Network ) execution completed =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "
echo

exit 0
