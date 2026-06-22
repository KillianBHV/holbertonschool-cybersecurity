# The Vulnerable Dockerfile 
## 1. Non-specific version chosen
- **Problem:** on a production server, if a server don't choose a fixed version, it can affect development processes and desynchronise operations.
- **Why:** It can lead to misinterpretations of data and logic between usages in time.
- **Attack:** an attacker can force docker to change interpreter versions

## 2. Unneccesary packets installed
- **Problem:** gcc and make are installed. Development should never be installed on production systems because of their purposes.
- **Why:** Because they can create programs with source code, they can bypass software security processes.
- **Attack:** an attacker connects to the docker and injects source ready to compile. With gcc and make, it may effectively create malicious programs with imported codes and payloads.

## 3. Clear Passwords
- **Problem:** With ENV and RUN directives, we see passwords directly encoded in cleartext 
- **Why:** Files are readable and allow us to see raw data directly. If this raw data is directly cleartext, it can be exploited
- **Attack:** An attacker has access to the config file, by an internal and external way and may use the printed credentials as is.

## 4. Unappropriate user for database usage
- **Problem:** The chosen user for database credentials seems too privileged.
- **Why:** It and can leads to database corruptions and leaks.
- **Attack:** With stolen credentatials methods or credentials recovering way, an attacker may use them in order to appear legitimate for the database.

## 5. All is executed as root
- **Problem:** The effective rights executes everything as root user
- **Why**: There's no check of who may do what, root does everything
- **Attack**: By the root credentials corruption, complete access to the docker filesystem, and even the host filesystem if possible.

## 6. Bad COPY instruction usage
