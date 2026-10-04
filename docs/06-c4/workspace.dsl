workspace "Служба такси" "Архитектурная модель системы" {

    model {
        passenger = person "Пассажир" "Заказывает поездку, отменяет заказ и оценивает поездку"
        driver = person "Водитель" "Получает и принимает заказ, выполняет поездку"
        payment = softwareSystem "Платёжный сервис" "Обрабатывает оплату поездки" "Внешняя"
        maps = softwareSystem "Сервис карт и маршрутов" "Определяет координаты и строит маршрут" "Внешняя"
        taxi = softwareSystem "Служба такси" "Оформление заказов, подбор водителей, расчёт стоимости и управление поездками" {
            passengerApp = container "Приложение пассажира" "Заказ, отмена и оценка поездки" "Android / Kotlin"
            driverApp = container "Приложение водителя" "Получение и принятие заказов" "Android / Kotlin"
            api = container "Backend API" "Единый API для клиентских приложений" "Kotlin / Spring Boot"
            orderService = container "Сервис заказов и поездок" "Создание заказов, расчёт стоимости и управление поездками" "Kotlin / Spring Boot" {
                orderComponent = component "OrderComponent" "Управление заказом; класс ПР1: Заказ" "Kotlin"
                tripComponent = component "TripComponent" "Управление поездкой; класс ПР1: Поездка" "Kotlin"
                routeComponent = component "RouteComponent" "Работа с маршрутом; класс ПР1: Маршрут" "Kotlin"
                tariffComponent = component "TariffComponent" "Расчёт стоимости; класс ПР1: Тариф" "Kotlin"
                paymentComponent = component "PaymentComponent" "Подготовка и выполнение оплаты; класс ПР1: Платёж" "Kotlin"
                ratingComponent = component "RatingComponent" "Работа с оценкой завершённой поездки; класс ПР1: Оценка" "Kotlin"
            }
            driverService = container "Сервис подбора водителя" "Поиск свободного подходящего водителя и его назначение" "Kotlin / Spring Boot"
            db = container "Основная БД" "Пользователи, заказы, поездки, тарифы, платежи" "PostgreSQL" "Database"
            bus = container "Очередь событий" "Передача событий между компонентами системы" "RabbitMQ" "Queue"
        }
        passenger -> passengerApp "Пользуется" "HTTPS"
        driver -> driverApp "Пользуется" "HTTPS"

        passengerApp -> api "Вызывает" "JSON/HTTPS"
        driverApp -> api "Вызывает" "JSON/HTTPS"

        api -> orderService "Передаёт запросы" "HTTP"
        api -> driverService "Передаёт запросы" "HTTP"

        orderService -> db "Читает и записывает" "JDBC"
        driverService -> db "Читает данные" "JDBC"

        orderService -> bus "Публикует события" "AMQP"
        bus -> driverService "Доставляет события" "AMQP"

        orderService -> maps "Получает маршрут" "HTTPS"
        orderService -> payment "Передаёт данные для оплаты" "HTTPS"

        orderComponent -> routeComponent "Использует маршрут"
        orderComponent -> tariffComponent "Рассчитывает стоимость"
        orderComponent -> driverService "Запускает подбор водителя" "HTTP"
        orderComponent -> paymentComponent "Создаёт платёж"
        orderComponent -> bus "Публикует события" "AMQP"
        orderComponent -> tripComponent "Создаёт и изменяет поездку"
        orderComponent -> db "Читает и записывает заказ" "JDBC"

        tripComponent -> routeComponent "Использует маршрут"
        tripComponent -> ratingComponent "Передаёт данные для оценки"
        tripComponent -> db "Читает и записывает поездку" "JDBC"

        routeComponent -> maps "Получает маршрут" "HTTPS"
        tariffComponent -> db "Читает тариф" "JDBC"

        paymentComponent -> payment "Передаёт данные оплаты" "HTTPS"
        paymentComponent -> db "Хранит данные платежа" "JDBC"

        ratingComponent -> db "Хранит оценку" "JDBC"
    }

    views {
        systemContext taxi "Context" {
            include *
            autolayout lr
        }
        container taxi "Containers" {
            include *
            autolayout lr
        }
        component orderService "Components" {
            include *
            autolayout lr
        }
        theme default
    }
}