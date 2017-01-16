import re
import json
import os
import sys

#Defining constants
HOME = os.environ['HOME']
BASH_HISTORY = HOME+"/.bash_history"
BASH_HISTORY_JSON = HOME+"/.bash_history.json"
debug=False
command_history=[]
ignore_commands=[]


def strip_command(command):
  command = command.lstrip()
  command = command.rstrip()
  command = command+"\n"
  if command[:5] == "sudo ":
    command = command[5:]
  return command


def process_command(command):
  if command_history.count(command):
    command_history.remove(command)
  command_history.append(command)


def ignore_command(command):
  for re_comm in ignore_commands:
    if re.match(re_comm, command) != None:
      if debug:
        print command, "Ignored", re_comm
      return True
  return False


def build_from_json():
  with open(BASH_HISTORY_JSON) as json_file:
    json_data = json.load(json_file)
  if debug:
    print json_data

  if "Options" in json_data.keys():
    for option in json_data["Options"]:
      regex = ".* "+option+"( .*)*$"
      ignore_commands.append(str(regex))

  if "Files" in json_data.keys():
    for files in json_data["Files"]:
      regex = ".* "+files+"( .*)*$"
      ignore_commands.append(str(regex))

  if "Commands" in json_data.keys():
    commands_dict = json_data["Commands"]
    for command in commands_dict.keys():
      command_type = commands_dict[command]["CommandType"]
      if command_type == 0:
        ignore_commands.append(str("("+command+")"))
      elif command_type == 1:
        regex = command+"( .*)*$"
        ignore_commands.append(str(regex))
      elif command_type == 2:
        command_arguments = commands_dict[command]["Arguments"]
        for args in command_arguments:
          regex = command+" "+args+"( .*)*$"
          ignore_commands.append(str(regex))
  if debug:
    print ignore_commands


def usage():
  print "Usage: python "+script_name+" [Debug]"
  print " Debug: Enable debugging messages (default is off)"
  sys.exit(0)


def main():
  global debug
  sys_args = sys.argv
  if len(sys_args) == 2:
    if sys_args[1] == "Debug":
      debug = True
    else:
      usage()
  elif len(sys_args) > 2:
    usage()

  # Reading json file to create regex patterns of the json commands
  build_from_json()

  #Opening bash history to read all the commands
  history_file = open(BASH_HISTORY, "r")
  for line in history_file:
    re_command = strip_command(line)
    if not ignore_command(re_command):
      process_command(re_command)
  history_file.close()

  #Opening bash history file to write processed commands
  history_file = open(BASH_HISTORY, "w")
  for command in command_history:
    history_file.write(command)
  history_file.close()


#Calling main
if __name__ == "__main__":
  main()
