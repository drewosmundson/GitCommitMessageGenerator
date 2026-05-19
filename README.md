# GitCommitMessageGenerator
I have RTX3060 with 16GB of ram qwen2.5-coder:7b seems to work well enough for this script for what I would like to acomplish.
A higher parameter count may be worth it but thats just not my style.
When you install this script then and do ollama pull [[YOUR_PREFERD_MODEL]]

Install Dependancies:


# Ubuntu/Debian
## Lua 
sudo apt install lua5.4
sudo apt install luarocks
luarocks install --local luasocket
luarocks install --local dkjson

## Ollama
curl -fsSL https://ollama.com/install.sh | sh
ollama serve
ollama pull qwen2.5-coder:7b 


# macOS
## Lua 
brew install lua
brew install luarocks
luarocks install --local luasocket
luarocks install --local dkjson

## Ollama
curl -fsSL https://ollama.com/install.sh | sh




## How to set this script up as an alias. 
Open your config file:
For Bash: nano ~/.bashrc
For Zsh: nano ~/.zshrc

Append the following line at the end of the file:
alias mylua='lua /path/to/your/script.lua


Apply the changes:
Run source ~/.bashrc (or .zshrc) to reload the configuration.

Run:
Type mylua in the terminal to execute the script.






