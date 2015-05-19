@echo  off
setlocal EnableDelayedExpansion

set count=0

for %%f in (*.png) do echo %%f
for %%s in (*.png) do rename %%s face!count!@2x.png && set /a count+=1
pause