+++
title = "Putting an Airport card into Thinkpad T440p"
+++

{{ image(src="Card.jpg", alt="Airport Card in a T440p") }}

As you probably know, there are two cards that are officially physically compatible with T440p and work on macOS (almost) out of the box: **DW1830** and **DW1560**. Both of these cards are pretty expensive (90-120€ and 50-70€ respectively) and difficult to source (sellers are often out of stock due to the high demand).   

So I started looking for alternative solutions and eventually decided to buy an [NGFF to Airport adapter](https://www.ebay.de/itm/BCM94360CS2-BCM943224PCIEBT2-12-6-Pin-WIFI-wireless-card-module-to-NGFF-Gut-CC/233302599936) and a [BCM943224PCIEBT2](https://www.ebay.de/itm/MacBook-Air-2010-2011-2012-BCM943224PCIEBT2-AirPort-WLan-BlueTooth-Board/173902975009?ssPageName=STRK%3AMEBIDX%3AIT&_trksid=p2057872.m2749.l2649) Airport card from a Macbook Air (18€ in total), and try my luck.  


### Some considerations
*  Please bear in mind that this is a higly experimental method. The results might be different for you, and this is **by no means** a 100% final working method. There's no guarantee, so do it at your own risk
* Make sure you know what you're doing, since the guide involves taking the laptop apart and this process is not for the faint of heart.

### Preparations
Remove [Wi-Fi whitelist](@/blog/2020-06-17-removing-the-wifi-whitelist/index.md) in your BIOS if you haven't done that yet.

Modify the NGFF adapter, since it won't fit into the T440p. Use diagonal pliers (cutters) to cut off a part of the adapter (be careful not to touch **contacts** on the left side – slightly left to a "pb" label on the picture):  
{{ image(src="adapter.png", alt="Cutting the adapter") }}

### Disassembly
Dissassemble the laptop – you will need to remove:
* External battery
* Big door
* CMOS battery
* Webcam cable
* Fan cable
* DVD drive
* Keyboard and keyboard bezel
* Base cover assembly

Refer to [Lenovo Maintenance Manual](https://thinkpads.com/support/hmm/hmm_pdf/t440p_hmm_en_sp40a25467_01.pdf) for instructions. There are a few plastics snaps around the docking station connector that are pretty tight, apply a little bit of force when you take off the base cover assembly and it should come right off.

After you removed the base cover assembly, disconnect the _Ethernet controller_ here:  
{{ image(src="Ethernet.png", alt="Ethernet controller location") }}

Screw the adapter to the motherboard and insert the Airport card into the adapter. Then, lift the Airport card from the adapter and try to "sandwich" the rear part of the Ethernet controller between the adapter and the card, as shown here (sorry for the madskillz):  
{{ image(src="scheme.jpg", alt="Scheme") }}

Finally, connect the Ethernet card to the motherboard, screw it in and assemble the laptop. Don't put the big door yet: there is a plastic hook on it that connects with the space between the Ethernet connector and the base cover assembly, which is now occupied by the Airport card. Use cutters to remove it.  
{{ image(src="hook.png", alt="Big door hook") }}

Turn the laptop on. It will display a message about CMOS battery and wrong checksum  – go to the BIOS settings and **restore default settings**. My laptop refused to boot until I did that, but YMMV.

**Voilá!** The card works out of the box with no additional configuration required!  
{{ image(src="screen.png", alt="System Report screenshot") }}

