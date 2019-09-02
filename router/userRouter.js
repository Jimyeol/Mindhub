var express = require('express');
var userRouter = express.Router();

//Session Data Form
const session = require('express-session');
const FileStore = require('session-file-store')(session);

userRouter.use(session({
    secret: 'keyboard cat',
    resave: false,
    saveUninitialized: true,
    store: new FileStore(),
}));

//Model Import
var userModel = require('../model/userModel');
var dataModel = require('../model/dataModel');

userRouter.get('/', function (req, res) {
    data = {
        userData: req.session.user
    }
    res.render('index.html',{data:data});
});

userRouter.get('/login', async (req, res) => {   
    res.render('login.html');
});

userRouter.post('/loginConfirmation', async (req, res) => {

    try {
        var result = await userModel.login(req);
        if(result[0].length > 0) {
            req.session.user = {
                userIndex : result[0][0].index,
                userID : result[0][0].id,
                userPW : result[0][0].password,
                userName : result[0][0].name,
                userAddr : result[0][0].address,
                userGen : result[0][0].gender,
                userPN : result[0][0].phonenumber,
                userDN : result[0][0].dnum,
            }
            console.log(req.session.user);
            res.redirect('/');
        } else {
            res.redirect('/login');
        }
    } catch (err) {
        console.log(err);
        res.status(500).send('LOGIN_FAILED');
    }

})

userRouter.get('/register', (req, res) => {
    res.render('register.html');
});

userRouter.post('/registerConfirmation', async (req, res) => {

    try {
        var result = await userModel.register(req);
        data = {
            userData: result
        }
        res.render('index.html', {data:data})
        
    } catch (err) {
        console.log(err);
        res.status(500).send('LOGIN_FAILED');
    }

})

userRouter.get('/logout', (req, res) => {
    if(req.session.user) {
        req.session.destroy(err => {
            console.log('failed: ' + err);
            return;
        });
        console.log('success');
        res.status(200).redirect('/');
    } else return;
});

userRouter.get('/myinfo',(req, res) => {
    data = {
        userData: req.session.user
    }
    res.render('myinfo.html',{data: data});
});

module.exports = userRouter;