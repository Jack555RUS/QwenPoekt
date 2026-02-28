using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using ProbMenu;
using ProbMenu.Interfaces;
using ProbMenu.Services;

var host = Host.CreateDefaultBuilder(args)
    .ConfigureServices((context, services) =>
    {
        // Регистрация сервисов
        services.AddSingleton<ICounterService, CounterService>();
        services.AddSingleton<IColorService, ColorService>();
        
        // Регистрация форм
        services.AddTransient<Form1>();
    })
    .Build();

// Настройка приложения
ApplicationConfiguration.Initialize();

// Запуск формы через DI
var form = host.Services.GetRequiredService<Form1>();
Application.Run(form);
