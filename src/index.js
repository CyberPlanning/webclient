import '../bower_components/normalize-css/normalize.css'
import './main.css';
import './calendar.css';
import './calendar.black.css';
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

Main.embed(document.getElementById('root'));

registerServiceWorker();
