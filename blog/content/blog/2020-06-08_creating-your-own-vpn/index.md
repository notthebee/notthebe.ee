+++
title = "Setting up an OpenVPN server from scratch on Ubuntu 20.04"
+++

{{ image(src="openvpn-logo.png", alt="OpenVPN Logo") }}
## Choosing a provider

In order to set up a VPN we need to find where we're going to host it.

There are a lot of VPS providers that offer servers for as little as $2 per month, but there are a few things that you need to consider when choosing a VPS provider:

1. **Virtualisation technology** — make sure your provider uses KVM or Xen instead of OpenVZ. OpenVZ is a container based virtualisation technology used on the cheapest bottom of the barrel VPS plans. OpenVZ machines run an old Linux kernel which isn't supported by Wireguard, Docker and other modern software and the way OpenVZ is built lets your provider snoop on your activities and files very easily. Avoid it
2. **An IPv4 address** — this only applies to the ultra budget VPS options, but some of the providers only give you an IPv6 address. This is not as common nowadays, but because of the shortage of IPv4 addresses we might start seeing it more and more often
3. **Location** – pretty self-explanatory. If you want to watch American content – choose an American data center. If you want to torrent Linux ISOs, don't choose Germany or Austria because they have very strict anti-piracy laws. If you want to use your VPN for gaming, keep in mind that the further the server, the bigger the latency. If you're really serious about privacy, choose a VPS outside of the 14 eyes.

In this tutorial I will be using [Linode](https://linode.com/)

## Setting up an account

After you sign up on the website and confirm your email, you're going to need to enter some details, including your name, address and credit card information. That's going to be pretty much the same for all VPS providers though sometimes they accept Bitcoin or other cryptocurrencies.

## Creating a VPS

Next thing you need to do is add a server or as Linode calls it, a "linode". There's a lot of distros to choose from, if you want you can even go with Gentoo or Arch, but for this tutorial I'll go with the latest version of Ubuntu.

You'll also want to choose the location, I'm going to choose UK since it's the closest to me physically.

We're going to take the cheapest "Nanode" plan. And even if later on you decide to set up a mail server, a Nextcloud instance or a personal blog, this configuration will still be more than sufficient.

Linode Label is not that important, and neither are tags. I'll call mine wolfgangsvpn.

After that you'll need to choose a root password and upload an SSH key, which we're not going to do now, i'll explain why later. Lastly tick a box that says "Private IP" and click the create button on the right... and there we go, our server is now created.

## Generating SSH keys

Now you should see the control panel of your server, and while the server is starting, let's generate the SSH keys for it. Using a cleartext password to log in to your server is never a good idea since the password is not encrypted in transit and can be exposed on a hostile network. By creating an SSH key we're going to make it so that you can only log in to the server if you have the key file and the password, and at the same time the password is encrypted.

If you're using Linux you probably already know how to open the terminal, if you're on Mac you can find the Terminal app in your Applications folder, and on Windows 10 you'll need to open the PowerShell with administrator's privileges and install SSH using this command:

```powershell
PS C:\> Add-WindowsCapability -Online -Name OpenSSH.Client*
```

This is the command that will generate our ssh keys. The RSA algorithm with 4096 key size is what I'd personally recommend, since it's sufficiently secure and widely supported.

```bash
ssh-keygen -t rsa -b 4096
```

Press Enter when asked for the key location to save it to the default one and then enter your password of choice.

## Logging in to the server

By now our server has started up and we're ready to log in. Copy the IP address from the server control panel, go back to the terminal and type in

```bash
ssh root@ip-address
```

Type yes, enter the root password that you specified in the first step and that's it, we're in.

## Updating the OS

First and foremost, let's update our operating system and software:

```bash
apt-get update && apt-get upgrade
```

I'll also install my favourite text editor, feel free to use whatever you want though, for example nano.

```bash
apt install neovim
```

## Creating a user

As much as it's convenient to not have to enter a password every time, we need to create a user account that isn't root. Exposing root login on an SSH server is probably not a good idea even if you have multi factor authentication. Call me paranoid, but I think having to enter root password sometimes is the price I'm willing to pay for some sense of security. Type

```bash
useradd -G sudo -m wolfgang -s /bin/bash
```

That's going to create a user, set bash as default shell for him and permit sudo usage.

Afterwards we'll need to create a password for our user, using

```bash
passwd wolfgang
```

Enter your password twice and we're good to go.

## Copying SSH key from host to the server

Now that we've created our user it's a good time to copy the public SSH key to the server. Open a second terminal window for your local terminal and enter:

### Linux or Mac
```bash
ssh-copy-id wolfgang@ip_address
```

### Windows
```
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh ip-address "cat >> .ssh/authorized_keys"
```

You'll be prompted to enter your password and once you do, go back to the terminal window with your server. Don't close the other window yet.

## Restricting SSH to key authentication

Now that we've copied the SSH keys to the server we have to restrict authentication to the public key only. Let's edit the sshd configuration file

```bash
nvim /etc/ssh/sshd_config
```

First of all, let's change the default port. This won't do much for security, but it will help with those obnoxious SSH scanners that try to log in with default credentials. Not much, but the security logs will definitely get easier to read. You can use any port that's not taken by other services, but I prefer to use 69. Nice

```bash
# Port 22
Port 69
```

Next, we need to disable password authentication so that you're only able to log in using a public key.

```bash
PasswordAuthentication no
```

Last but not least, let's also disable root login

```bash
PermitRootLogin no
```

Now save the file and restart the sshd service using

```bash
systemctl restart sshd
```

Now without closing this window let's go back to our local machine and try to log in with our key:

```bash
ssh -i ~/.ssh/id_rsa wolfgang@ip_address -p 69
```

If you see the prompt to enter your key password, that means we're good to go. It's also a good idea to verify that we can't log in with our password anymore:

```bash
ssh wolfgang@ip_address -p 69
```

This should give us "Permission denied".

## Creating a server alias

But you might have noticed that this command is kind of long and annoying to type, so let's fix that. Create a file in the ".ssh" folder in your home directory called "config" and edit it using your favourite text editor:

```bash
nvim ~/.ssh/config
```

Here we're going to create an alias for our VPS

```bash
Host wolfgangsvpn # choose a name for your server   
	User wolgang # the username of the user that we created
  	Port 69
  	IdentityFile ~/.ssh/id_rsa # that's the location of our key file
	HostName ip_address # that's the IP address of our server
```

Save and close, and now we can login to our server by simply typing `ssh wolfgangsvpn`

If you also don't want to see this wall of text every time you login, type in `touch .hushlogin`

## Setting up OpenVPN

I know that Wireguard has been the hot new VPN protocol that everyone's been focused on lately, but in this video I'm going to use OpenVPN instead. Why? Because it has wider support when it comes to client applications and some of the applications that I'll be talking about in the 2nd part of this tutorial utilize OpenVPN. If you're interested in setting up a Wireguard server, there are a lot of tutorials on the Internet about it.

Normally setting up an OpenVPN server takes some time since you need to install the packages, generate the keys, set up IPTables, write the config files for the server and the client. Thankfully, we won't do any of this in the tutorial and instead we'll use the OpenVPN road warrior script from a github user called Nyr - https://github.com/Nyr/openvpn-install. This script will do all the hard work for us and all we have to do is answer a few simple questions and download the config file at the end. Needless to say you shouldn't just go around executing random scripts you downloaded from the internet, so if you know some bash, read the script first and make sure there's nothing fishy in there. If you don't know any bash, maybe send it to a friend who does. When you done with the perusal of the script, click raw and copy the link from your browser.

Log in to your server and install `wget` if you haven't already. Sometimes it comes with your OS image already, but sometimes it doesn't.

```bash
sudo apt install wget
```

Next, type `wget`, press Space and paste the link that you copied earlier. Press Enter

Now let's launch the script

```bash
sudo bash openvpn-install.sh
```

The script will ask you some questions, and in most cases you'll want to pick the default answer. For the port, you can either choose the default port, 1194, but I prefer to choose 443, since 1194 is known as "the OpenVPN port" and in some cases it can be blocked on your network. 443 is the same port that is used for HTTPS, but whereas HTTPS uses TCP, OpenVPN (in this configuration) uses UDP, so they won't conflict with each other.

You're also going to be asked which DNS you want to use. Feel free to choose whatever you like, but I normally choose 1.1.1.1

As for the client name, choose whatever you like.

Now that the configuration is done, press any key and the installation process is going to start. It's fully automated and at the end you'll going to get a configuration file that we'll download to our local machine later on. The problem is that the script places the file in the root directory by default, and in order to download it later, we need to move it to our user's home directory and give ourselves the correct priviliges:

```bash
sudo mv /root/thinkpad.ovpn ~
sudo chown wolfgang thinkpad.ovpn
```

With this out of the way there's only one thing left to be done on the server's side, and that's to disable the logs. Let's edit the config file:

```bash
sudo nvim /etc/openvpn/server/server.conf
```

And change `verb 3` to `verb 0`

Now restart the OpenVPN service:

```bash
systemctl restart openvpn-server@server.service
```

And there we go! A VPN that **actually** doesn't keep logs. Amazing.

I also just noticed that the hostname of the server is "localhost", which is not cool for many reasons. So let's change it to something else, I'm going to call it "wolfgangsvpn"

## Downloading the config file

Now all we need to do is to download the configuration file to our local machine so that we can actually use the VPN. Open a terminal on your local machine and type in `sftp servername` Next, download the file using the command `get configname.ovpn`. And finally type `exit`

Now if you want to use this VPN for all your traffic, which I don't recommend, you can download [Tunnelblick](https://tunnelblick.net/) on Mac, [OpenVPN Connect](https://openvpn.net/client-connect-vpn-for-windows/) on Windows or load it into the NetworkManager on Linux. 

## Nice to have

At this point we have a barebones VPN server up and running. You can stop here and use it like you would normally use a VPN (in which case thanks for reading and i'm glad I could help), but if you want to know how to make it even more secure and add some features that are nice to have, like unattended upgrades, keep reading.

## Optional: Installing mosh

Now, ssh is nice but it does get annoying sometimes, especially when you change your network and your connection drops immediately. Instead, I prefer to use mosh. There's no complicated config file shenenigans, you just install mosh on both your local and your remote machine, and after that you can simply use the `mosh` command as a drop-in replacement for `ssh`

## Optional: Setting up multi-factor authentication

Now, public key authentication is probably secure enough for most, but if you want to be extra fancy, you can also add MFA or multi-factor authentication. The way it works is you install an app on your phone (there are a lot of open source apps on Android like AndOTP) and every time you log in you get a one time password in the app which you need to enter in order to log in. This provides an additional layer of security for your server which can be useful for some of us who are especially paranoid.

The first thing you have to do is to install `google-authenticator-libpam` Yes, the protocol is made by Google, but it's completely open-source and you don't have to use the Google Authenticator app on your phone, there are many open source options as I've already mentioned

```bash
sudo apt install libpam-google-authenticator
```

After that, launch the initialization script by typing `google-authenticator` . There, basically answer yes to all questions except for the one about multiple users and the one about 30 second tokens.

Once you've done that, you might have noticed a big QR code in your command line as well as the recovery codes. Make sure to write those codes down somewhere save, they'll be useful in case you lose the access to the app on your phone. After that what you need to do is launch the authenticator app on your phone, I'll use OTP Auth, add a new account and chooe "Scan a QR code". After you scan the code, the account will be added to the app. And we're done with the phone part for now.

Let's go back to the server terminal and edit the authentication settings file for sshd:

```bash
sudo nvim /etc/pam.d/sshd
```

Here we'll comment out the line that says `@include common-auth`. Normally the two factor authentication will ask you for your user password and the one time password, but since we're already using a public key with the password, having to enter your password twice is slightly annoying. That way you'll only have to enter the public key password and the one time password.

Next we need to add this line to the end of the file:

```bash
auth required pam_google_authenticator.so
```

Let's save the file and quit. Now we need to edit the SSHD configuration file to make SSH aware of the new authentication method:

```bash
sudo nvim /etc/ssh/sshd_config
```

Here we need to change the following lines:

```bash
ChallengeResponseAuthentication yes
UsePAM yes
```

And add a new line after UsePAM that says:

```bash
AuthenticationMethods publickey,password publickey,keyboard-interactive
```

That's it, let's save the file and exit. And now let's restart the SSH service for the changes to take effect:

```bash
sudo systemctl restart sshd
```

As I mentioned in the beginning, it's always a good idea to try and log in in a separate terminal window without closing the server session. Otherwise if you messed up you'll be locked out of the SSH and obviously you don't want that.

If you try to log in now you'll see that apart from the usual public key password you're also going to be asked for the one time password from your app. Once again, if you're using Gnome, you won't be prompted for the public key until you log out and log back in again, only the one time password from your phone app. Let's enter the password and voila! Now our server is secured by two-factor authentication.

## Optional: Unattended upgrades

One last thing that I want to show you today is unattended software upgrades. What this means is we're going to have a script that runs `apt update` and `apt upgrade` regularly, thus liberating us from the burden of having to log in to the server and do this manually. The server will also be rebooted for kernel updates, but since the reboot takes less than a minute, and since kernel updates are not very frequent, your VPN won't actually have much downtime because of the upgrades. You can also disable the automatic reboots if you prefer to do it yourself.

So the first thing we need to do is to install the unattended-upgrades package:

```bash
sudo apt install unattended-upgrades apt-listchanges bsd-mailx
```

Next, enable the stable security updates:

```bash
sudo dpkg-reconfigure -plow unattended-upgrades
```

After that's done, let's edit the config file

```bash
sudo nvim /etc/apt/apt.conf.d/50unattended-upgrades
```

Here we need to set our email address which is going to be used for update notifications:

```bash
Unattended-Upgrade::Mail "mail@example.com";
```

And then also enable automatic reboots, set up cleanup tasks for removing unused kernels and set the automatic reboot time at 5AM.

```bash
Unattended-Upgrade::Automatic-Reboot "true";  # this is kind of obvious
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "true";
Unattended-Upgrade::Automatic-Reboot-Time "05:00"; # here we'll specify when we want our system to reboot
```

That's it! Let's see if it works

```bash
sudo unattended-upgrades --dry-run
```

So now your system and all the packages will be updated automatically and you'll get an email every time an upgrade has been performed.
