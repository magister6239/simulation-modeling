using Pkg
Pkg.add("DrWatson")
using DrWatson
project_name = "project"
initialize_project(project_name; authors="Перегудов Александр", git=false)
println("✅ Проект создан: ", project_name)
println("� Перейдите в директорию: cd ", project_name)