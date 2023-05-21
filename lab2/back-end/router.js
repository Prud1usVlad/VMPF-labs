import express from 'express';
import { deleteItem, getUserItems, postItem, putItem, setViewed } from './itemsController.js';
import { getUser, logIn, register } from './userController.js';

const router = express.Router();

router.post("/auth/login", logIn);
router.post("/auth/register", register);
router.get("/auth/user/:id", getUser);
router.get('/items/:userId', getUserItems);
router.post('/items', postItem);
router.put('/items/:id', putItem);
router.delete("/items/:id", deleteItem);
router.put("/items/viewed/:viewed/:id", setViewed);

export default router;