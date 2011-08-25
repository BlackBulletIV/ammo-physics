local path = ({...})[1]:gsub("%.init", "")
require(path .. ".PhysicalEntity")
require(path .. ".PhysicalWorld")
