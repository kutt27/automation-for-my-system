Update: Still have issues with the setup due to some problems with environment and the configuration. Will udpate it soon.

### Tool that's going to be used:

- docker-compose
- Linkwarden

#### Make sure

Requirements for the work

- SBC (I use a pi 4 for this setup 64 bit architecture)
- docker-compose
- No issues with docker and your device
- Update the time of your server

For Pi:

```bash
sudo raspi-config
```

- Select “Localisation Options”
- Choose “Change Time Zone”
- Pick geographic area (for India, select “Asia”) and city (“Kolkata” for IST).

Also,

```bash
sudo timedatectl set-ntp true
date # timedatectl
```

### Update the system

```sh
sudo apt update
sudo apt upgrade -y
```

### Clone the repository of linkwarden

```sh
git clone https://github.com/linkwarden/linkwarden.git
cd linkwarden
```

### Prepare secrets

```sh
for i in {1..3}; do
    openssl rand -base64 32
done
```

Save all the files one by one, we need three keys for this operation.

### Configure environment

We are in the directory `~/linkwarden`

Run:

```sh
nano .env
```

Then, edit this file for environment config setup

```sh
NEXTAUTH_SECRET=<YOUR_FIRST_KEY>
POSTGRES_PASSWORD=<YOUR_SECOND_KEY>
NEXTAUTH_URL=http://localhost:3000
MEILI_MASTER_KEY=<ANOTHER_RANDOM_KEY>
```

### docker-compose 

```sh
docker compose up -d
```

### ..



### Problem I faced

I got errors for which the dns doesn't resolve the address, therefore avoiding potential downloads from the server. But the problem was that, my resolv.conf keep changing the dns address to the router, which causing the error, I go back and forth to resolve the issue, updating the files with google dns address of `8.8.8.8 8.8.4.4`. Didn't worked for the whole day, after careful observation and patience, I came with some conclusion:

- The system writing back the configurations files after restart (the restart needed for applying changes)
- Limiting myself update and it goes back after the restart take place.
- Found out the system is not managed by `dhcpcd` but `NetworkManager`.
- Identified the connection name and with that I updated the dns address and the issue now solved.
