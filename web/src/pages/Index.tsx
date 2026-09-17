import { PriviaApp, DemoUnavailable } from "../privia/PriviaApp";
import { PriviaProvider } from "../privia/store";
import { DEMO_ENABLED } from "../privia/model";

const Index = () => DEMO_ENABLED ? <PriviaProvider><PriviaApp /></PriviaProvider> : <DemoUnavailable />;

export default Index;
