import shutil

total, used, free = shutil.disk_usage('b:\\')
tb=pow(1024,4)
total= round(total/tb,2)
used=round(used/tb,2)
free=round(free/tb,2)
print(total, used, free)
