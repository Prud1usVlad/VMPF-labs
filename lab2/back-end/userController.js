import { User } from "./models.js";


export const logIn = async (req, res) => {
    try {
        const users = await User.findAll({
            where: {
                email: req.body.email
            },
        });

        let found = false;

        users.forEach(el => {
            if (el.password === req.body.password) {
                found = true;
                res.status(200).json({success: true, message: "Log in successful", id: el.id});
            }
        });

        if (!found) {
            throw "Login error";
        }
    } catch (error) {
        res.status(400).json({ success: false, error: error });
    }
} 

export const register = async (req, res) => {
    try {
        const user = await User.create(req.body);
        res.status(201).json({ success: true, message: "Registered successfully", id: user.id})
    } catch (error) {
        res.status(400).json({ success: false, error: "Registration error" });
    }
} 

export const getUser = async (req, res) => {
    try {
        const users = await User.findAll({
            where: {
                id: req.params.id,
            },
        });

        res.status(200).json(users[0]);
    } catch (error) {
        res.status(400).json({ success: false, error: error });
    }
}