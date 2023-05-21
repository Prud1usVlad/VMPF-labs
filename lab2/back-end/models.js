import { DataTypes, Sequelize } from "sequelize";

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database.db'
});

export const User = sequelize.define("User", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
        unique: true,
    },
    email: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
    password: {
        type: DataTypes.STRING,
        allowNull: false,
    }
})

export const Item = sequelize.define("Item", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
        unique: true,
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    name: {
        type: DataTypes.STRING,
        defaultValue: "none"
    },
    cover: {
        type: DataTypes.STRING,
        defaultValue: "none"
    },
    director: {
        type: DataTypes.STRING,
        defaultValue: "none"
    },
    description: {
        type: DataTypes.STRING,
        defaultValue: "none"
    },
    type: {
        type: DataTypes.STRING,
        defaultValue: "film"
    },
    rate: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    },
    viewed: {
        type: DataTypes.INTEGER,
        defaultValue: 0
    }
})



export const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('Connection has been established successfully.');
    } catch (error) {
        console.error('Unable to connect to the database:', error);
    }
}
