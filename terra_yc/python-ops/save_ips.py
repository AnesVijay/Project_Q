from subprocess import run, PIPE
from pathlib import Path

def main():
    root_path = str(Path(__file__).parents[2])

    ips = {
        "gitlab" : "-1",
        # "coders" : "-1",
        "production" : "-1",
        "monitor" : "-1"
    }

    for key in ips.keys():
        proc = run(["terraform", "output", f"{key}-server-ip"], stdout=PIPE)
        ips.update({ key : proc.stdout.decode('utf-8').split()[0]})

    with open(f"{root_path}/ansible/hosts.ini", 'r') as f:
        hosts_data = f.readlines()

    for i in range(len(hosts_data)):
        if hosts_data[i].startswith("gitlab"):
            hosts_data[i] = f"gitlab ansible_host={ips['gitlab']}\n"
        # elif hosts_data[i].startswith("coders"):
        #     hosts_data[i] = f"coders ansible_host={ips['coders']}\n"
        elif hosts_data[i].startswith("prod"):
            hosts_data[i] = f"prod ansible_host={ips['production']}\n"
        elif hosts_data[i].startswith("monitor"):
            hosts_data[i] = f"monitor ansible_host={ips['monitor']}\n"

    with open(f"{root_path}/ansible/hosts.ini", "w") as f:
        f.writelines(hosts_data)


if __name__ == "__main__":
    main()