/*
 * ANDES Lab - University of California, Merced
 * This class provides the basic functions of a network node.
 *
 * @author UCM ANDES Lab
 * @date   2013/09/03
 *
 */
#include <Timer.h>
#include "includes/command.h"
#include "includes/packet.h"
#include "includes/CommandMsg.h"
#include "includes/sendInfo.h"
#include "includes/channels.h"

module Node{
   uses interface Boot;

   uses interface SplitControl as AMControl;
   uses interface Receive;

   uses interface SimpleSend as Sender;

   uses interface CommandHandler;

    user interface List<pack> as PacketList;            //Creats Listed of type pack with name PacketList

}

implementation{

   uint16_t counter = 0;             //Create a counter and initizalled to 0


   pack sendPackage;

   // Prototypes
   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t Protocol, uint16_t seq, uint8_t *payload, uint8_t length);

    bool findPackage(pack *Package);            //Creation of findPackege (implmented below)
    void pushPack(pack Package);                /Creation of pushPack (implmented below)

   event void Boot.booted(){
      call AMControl.start();

      dbg(GENERAL_CHANNEL, "Booted\n");
   }

   event void AMControl.startDone(error_t err){
      if(err == SUCCESS){
         dbg(GENERAL_CHANNEL, "Radio On\n");
      }else{
         //Retry until successful
         call AMControl.start();
      }
   }

   event void AMControl.stopDone(error_t err){}

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
      dbg(GENERAL_CHANNEL, "Packet Received\n");
      if(len==sizeof(pack)){
         pack* myMsg=(pack*) payload;

 /*   if ( (myMsg->TTL == 0) || (findPackage(myMsg))) {           //Do nothing if the packets if its TTL has ran out or if already seen
        dgb("Packet Dropped: seq3%d from %d\n", myMsg->seq, myMsg->src);

    }
    else if (myMsg->dest == AM_BROADCAST_ADDR) {              //Check for correct ID
        dbg(GENERAL_CHANNEL, "Package Payload: %s\n", myMsg->payload);          //Return payload.

        makePack(&sendPackage, TOS_NODE_ID, myMsg->src, MAX_TTL, PROTOCOL_PINGREPLY, counter, (uint8_t *) myMsg->payload, sizeof(myMsg->payload));      //Make new pack
        counter++;                                                      //Increment our sequence number
        call Sender.send(sendPackage, AM_BROADCAST_ADDR);               //Re-broadcast

    } else if((myMsg->dest == TOS_NODE_ID)) {               //Check node ID of destination
        dbg(GENERAL_CHANNEL, "Packet from %d!\n", myMsg->src);   //Return packet source
        makePack(&sendPackage, TOS_NODE_ID, myMsg->src, MAX_TTL, PROTOCOL_PINGREPLY, seqCounter, (uint8_t *) myMsg->payload, sizeof(myMsg->payload));
        counter++;
        pushPack(sendPackage);
        call Sender.send(sendPackage, AM_BROADCAST_ADDR);
    }

    else {
        makePack(&sendPackage, myMsg->src, myMsg->dest, myMsg->TTL-1, myMsg->protocol, myMsg->seq, (uint8_t *)myMsg->payload, sizeof(myMsg->payload));      //make new pack
        dbg(GENERAL_CHANNEL, "Recieved packet from %d, meant for %d, TTL is %d. Rebroadcasting\n", myMsg->src, myMsg->dest, myMsg->TTL);        //Give data of source, intended destination, and TTL
        call Sender.send(sendPackage, AM_BROADCAST_ADDR);       //Re-broadcast
        }
        return msg;
    }
/*
      dbg(GENERAL_CHANNEL, "Unknown Packet Type %d\n", len);
      return msg;
   }


   event void CommandHandler.ping(uint16_t destination, uint8_t *payload){
      dbg(GENERAL_CHANNEL, "PING EVENT \n");
      makePack(&sendPackage, TOS_NODE_ID, destination, 0, 0, 0, payload, PACKET_MAX_PAYLOAD_SIZE);
      call Sender.send(sendPackage, destination);
   }

   event void CommandHandler.printNeighbors(){}

   event void CommandHandler.printRouteTable(){}

   event void CommandHandler.printLinkState(){}

   event void CommandHandler.printDistanceVector(){}

   event void CommandHandler.setTestServer(){}

   event void CommandHandler.setTestClient(){}

   event void CommandHandler.setAppServer(){}

   event void CommandHandler.setAppClient(){}

   void makePack(pack *Package, uint16_t src, uint16_t dest, uint16_t TTL, uint16_t protocol, uint16_t seq, uint8_t* payload, uint8_t length){
      Package->src = src;
      Package->dest = dest;
      Package->TTL = TTL;
      Package->seq = seq;
      Package->protocol = protocol;
      memcpy(Package->payload, payload, length);
   }

 /*   bool findPackage(pack *Package) {
        uint16_t size = call PacketList.size();
        uint16_t i = 0;
        pack Match;
        for(i = 0; i < size; i++) {
            Match = call PacketList.get(i);
            if(Match.src == Package->src && Match.dest == Package->dest && Match.seq == Package->seq) {
                return TRUE;
            }
        }
        return FALSE;


    void pushPack(pack Package) {
        if(call PacketList.isFull()) {
            call PacketList.popfront();
        }
        call PacketList.pushback(Package);
    }
/*

}
