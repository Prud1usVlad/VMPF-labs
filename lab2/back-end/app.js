import express from 'express';
import router from "./router.js"
import cors from 'cors';
import { testConnection } from './models.js';

const app = express();
const basicAddress = "/api";

app.use(express.json());
app.use(cors());
app.use(basicAddress, router)

app.listen(7000, () => 
{ 
    console.log('server is running at http://localhost:7000/api');
    testConnection();
})



