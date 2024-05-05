import time
import random
import git
from pathlib import Path
from datetime import datetime
from os import getenv as env

root_path = str(Path(__file__).resolve().parent.parent.parent) #./Project_q/.


def get_url(in_docker: bool):
    if in_docker:
        ip = env("GITLAB_IP")
    else:
        with open(f"{root_path}/hosts.ini", 'r') as f:
            s = f.readline().split()[1]
        ip = s.split('=')[1]
    return f"git@{ip}"


def get_vars(in_docker: bool) -> list:

    if in_docker:
        # token = env("GITLAB_TOKEN")
        g = env("GITLAB_GROUP_NAME")
        pn = env("GITLAB_PROJ_NAME")
        skc = "ssh -i " + env("PATH_TO_SSH_KEY")
    else:
        with open(f"{root_path}/gitlab-vars.yml", 'r') as f:
            for line in f.readlines():
                # if "gitlab_root_token" in line:
                #     token = line.split()[1]
                if "group_name" in line:
                    g = line.split()[1]
                elif "proj_name" in line:
                    pn = line.split()[1]
                elif "path_to_store_git_ssh_keys" in line:
                    skc = "ssh -i " + line.split()[1]
    # return [token, g, pn, skc]
    return [g, pn, skc]


in_docker = True if env("IN_DOCKER") == 'True' else False
gitlub_url = get_url(in_docker)
# private_token, 
group_name, project_name, ssh_key_cmd = get_vars(in_docker)
# gl = Gitlab(gitlub_url, private_token)
filename = env(key="FILENAME",default="main.py")


def clone_fetch_repo(local_path: Path, repo_url: Path):
    print("Clone_fetch")
    if local_path.exists():
        local_repo_instance = git.Repo(local_path)
        if len(local_repo_instance.remotes) > 0:
            origin = local_repo_instance.remotes[0]
        else:
            origin = local_repo_instance.create_remote("GitLab", repo_url)
        with local_repo_instance.git.custom_environment(GIT_SSH_COMMAND=ssh_key_cmd):
            origin.fetch()
            origin.pull()
    else:
        local_repo_instance = git.Repo.clone_from(url=Path(repo_url), to_path=local_path, env={"GIT_SSH_COMMAND": ssh_key_cmd})
        local_repo_instance.create_remote("GitLab", repo_url)
    return local_repo_instance


def make_change(path_to_file: Path):
    print("Changes")
    num = env("CODER_NUM")
    if not path_to_file.exists():
        path_to_file.touch()
    else:
        with open(path_to_file, "a+") as f:
            lines = f.readlines()
            if len(lines) > 1:
                if "print(\"Hello\")" in lines[0]:
                    date = datetime.today().strftime("%d %B, %Y")
                    time = datetime.now().strftime("%H:%M:%S")
                    f.write("\n")
                    f.write(f"------------this change made on {date} at {time}\n=> by coder #{num}\n")
            else:
                f.write("print (\"Hello World\")\n")


def commit_push_changes(repo: git.Repo):
    print("commit_push")
    repo.git.add(all=True)
    date = datetime.today().strftime("%d %B, %Y")
    time = datetime.now().strftime("%H:%M")
    repo.index.commit(f"Changes to {filename} on {date} at {time}")
    with repo.git.custom_environment(GIT_SSH_COMMAND=ssh_key_cmd):
        repo.remote("GitLab").push()


def simulate_developer_work():
    local_path = Path(f"{root_path}{project_name}")
    repo_url = f"{gitlub_url}:{group_name}/{project_name}.git"
    file_path = Path(f"{str(local_path)}/{filename}")

    repository_instance = clone_fetch_repo(local_path, repo_url)

    if file_path.exists():
        make_change(file_path)
    else:
        file_path.touch()
        make_change(file_path)

    commit_push_changes(repository_instance)


def main():
    max_time = env("MAX_DELAY")
    while (True):
        delay_seconds = random.randint(1, int(max_time))
        hours = int(delay_seconds / 60 / 60)
        if hours > 0:
            minutes = int((delay_seconds / 60) % hours)
        else:
            minutes = int(delay_seconds / 60)
        seconds = int(delay_seconds % 60)
        print(f"Waiting for {hours} hours, {minutes} minutes and {seconds} seconds before simulating developer work...")
        time.sleep(delay_seconds)
        print("Simulating developer work...")
        simulate_developer_work()


if __name__ == "__main__":
    main()
