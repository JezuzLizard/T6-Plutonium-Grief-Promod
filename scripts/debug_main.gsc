#include scripts/debug/event_logger;
#include scripts/debug/unit_tests/_timescale;
#include scripts/debug/unit_tests/_bots;

main()
{
	initialize_event_logger();
}

init()
{
	initialize_unit_test_bots();
}