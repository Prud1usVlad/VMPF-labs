import { Item } from "./models.js";

export const getUserItems = async (req, res) => {
    try {
        const items = await Item.findAll({
            where: {
                userId: req.params.userId 
            },
        });
        res.status(200).json(items);
    } catch (error) {
        res.status(400).json({ success: false, error: error });
    }
}

export const postItem = async (req, res) => {
    try {
        const item = await Item.create(req.body);
        res.status(201).json({ success: true, message: "Added successfully" })
    } catch (error) {
        res.status(400).json({ success: false, error: error });
    }
}

export const putItem = async (req, res) => {
    try {
        await Item.update(req.body, {
            where: {
                id: req.params.id
            }
        })
        res.status(200).json({ success: true, message: "Updated successfully" });
    } catch (error) {
        res.status(400).json({ success: false, error: error }); 
    }
}

export const deleteItem = async (req, res) => {
    try {
        await Item.destroy({
            where: {
              id: req.params.id
            }
        });
        res.status(200).json({ success: true, message: "Deleted successfully" });
    } catch (error) {
        res.status(400).json({ success: false, error: error }); 
    }
}

export const setViewed = async (req, res) => {
    try {
        await Item.update({viewed: req.params.viewed}, {
            where: {
                id: req.params.id
            }
        })
        res.status(200).json({ success: true, message: "Updated successfully" });
    } catch (error) {
        res.status(400).json({ success: false, error: error }); 
    }
}