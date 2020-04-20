using System;
using System.Threading.Tasks;
using DemoWebApp.Data;
using FluentAssertions;
using Test.It.With.XUnit;
using Xunit;

namespace DemoWebAppTests
{
    public partial class Given_a_forecast_service
    {
        public partial class When_getting_forecasts : XUnit2SpecificationAsync
        {
            private readonly WeatherForecastService _weatherForecastService = new WeatherForecastService();
            private WeatherForecast[] _forecasts;

            protected override async Task WhenAsync()
            {
                _forecasts = await _weatherForecastService.GetForecastAsync(
                    new DateTime(2020, 04, 20));
            }

            [Fact]
            public void It_should_retrieve_five_forecasts()
            {
                _forecasts.Should()
                    .HaveCount(5);
            }
        }
    }
}
