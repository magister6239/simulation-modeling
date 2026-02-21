using DrWatson
@quickactivate "project"
println("✅ Проект активирован: ", projectdir())
## Проверка пакетов
packages = [
"DrWatson",
# Организация проекта
"DifferentialEquations", # Решение ОДУ
"Plots",
# Визуализация
"DataFrames",
"CSV",
"JLD2",
"Literate",
"IJulia",
"BenchmarkTools",
"Quarto"
]
# Таблицы данных
# Работа с CSV
# Сохранение данных
# Literate programming
# Jupyter notebook
# Бенчмаркинг
# Создание отчетов
println("\nПроверка пакетов:")
for pkg in packages
try
eval(Meta.parse("using $pkg"))
println(" ✓ $pkg")
catch e
println(" ✗ $pkg: Ошибка загрузки")
end
end
## Проверка путей
println("\nСтруктура проекта:")
println(" Корень:          ", projectdir())
println(" Данные:          ", datadir())
println(" Скрипты:         ", srcdir())
println(" Графики:         ", plotsdir())