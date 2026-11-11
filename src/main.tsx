import React from 'react'; import ReactDOM from 'react-dom/client'; import App from './App'; import './styles.css';
ReactDOM.createRoot(document.getElementById('root')!).render(<React.StrictMode><App/></React.StrictMode>);
const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting)(e.target as HTMLElement).classList.add('revealed')}),{threshold:.12}); document.querySelectorAll('[data-moment]').forEach(x=>io.observe(x));
