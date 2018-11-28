# Multi Channel Network (MCN)
This is Multi Channel Network based on [Build Your First Network](https://github.com/hyperledger/fabric-samples). 
After the [tutorial](https://hyperledger-fabric.readthedocs.io/en/latest/build_network.html)
a Fabric beginner may want to find out multi channel network samples, and these are the samples.

## Network Diagram
There are 4 Orgs( org1, org2, org3, org4 )
Each org has one peer except org3 has two peers( peer0.org3 and peer1.org3 ).

There are 2 Private Channels.
Each channel consists of org's peers like bellow.
Channel1( peer0.org1, peer0.org2, peer0.org3 )
Channel2( peer1.org3, peer0.org4 )

![Network Diagram](https://raw.githubusercontent.com/nicezic0/fabric-multi-channel-samples/master/multi-channel-network/docs/multi-channel-network.PNG)
